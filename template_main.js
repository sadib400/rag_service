import fs from 'fs';
import express from 'express';
import axios from 'axios';
import bodyParser from 'body-parser';
import MCPModule from '@modelcontextprotocol/server-filesystem';
import dotenv from 'dotenv';
dotenv.config();

console.log("🔥 Booting server...");

const app = express();
app.use(bodyParser.json());

const directories = process.env.DIRECTORIES ? process.env.DIRECTORIES.split(',').map(dir => dir.trim()) : [];
const searchApiKey = process.env.SEARCH_API_KEY || null;
const MCP = MCPModule();
MCP.serve({ dirs: directories });

app.get('/', (req, res) => res.send('✅ Server is live'));

app.post('/chat', async (req, res) => {
    const query = req.body.message?.toLowerCase() || '';
    try {
        const results = await MCP.query(query);
        if (results && results.length > 0) {
            return res.json({ response: `[Local] ${results[0].text}` });
        }
    } catch (e) {
        console.error("Local query failed:", e);
    }
    if (searchApiKey) {
        try {
            const brave = await axios.get(`https://api.search.brave.com/res/v1/web/search?q=${encodeURIComponent(query)}`, {
                headers: {
                    'Accept': 'application/json',
                    'X-Subscription-Token': searchApiKey
                }
            });
            const top = brave.data.web?.results?.[0];
            if (top) {
                return res.json({ response: `[Brave] ${top.title} - ${top.url}` });
            }
        } catch (e) {
            console.error("Brave search failed:", e);
        }
    }
    return res.json({ response: "No matching results found locally or online." });
});

app.post('/read', (req, res) => {
    const filePath = req.body.path;
    if (!filePath) return res.status(400).json({ error: 'File path required' });
    try {
        const content = fs.readFileSync(filePath, 'utf-8');
        return res.json({ content });
    } catch (e) {
        return res.status(500).json({ error: 'Failed to read file' });
    }
});

app.post('/write', (req, res) => {
    const { path: filePath, content } = req.body;
    if (!filePath || !content) return res.status(400).json({ error: 'File path and content required' });
    try {
        fs.writeFileSync(filePath, content, 'utf-8');
        return res.json({ status: 'File created' });
    } catch (e) {
        return res.status(500).json({ error: 'Write failed' });
    }
});

app.post('/edit', (req, res) => {
    const { path: filePath, content } = req.body;
    if (!filePath || !content) return res.status(400).json({ error: 'File path and content required' });
    try {
        fs.writeFileSync(filePath, content, 'utf-8');
        return res.json({ status: 'File updated' });
    } catch (e) {
        return res.status(500).json({ error: 'Edit failed' });
    }
});

app.listen(3000, () => console.log("✅ Server running at http://localhost:3000"));
