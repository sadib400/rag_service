# 🔍 Local Filesystem AI Assistant (RAG Service)

This project builds a **fully local, privacy-respecting Retrieval-Augmented Generation (RAG) server** that allows a local LLM to read, search, and modify your computer's files via natural language — without uploading anything to the cloud.

---

## 🚀 What This Project Does

This system:

- Automatically sets up a **local server (http://localhost:3000)** every time your PC starts.
- Connects to **ChatD**, allowing you to chat with your local filesystem like an AI assistant.
- Reads folders you allow and:
  - 🔍 Searches your documents, code, or notes for answers
  - 📖 Reads any file’s content and sends it to the LLM
  - 📝 Edits or creates new files on command
- If nothing relevant is found locally, it can optionally:
  - 🌐 Fall back to online search using Brave Search API (if a key is provided)

---

## 💡 How It Works

1. **On first startup**, the `startup.bat` script:
   - Prompts you to select folders you want the assistant to access (e.g., `D:\docs`, `E:\projects`)
   - Prompts for paths to `chatd.exe` and `ollama.exe`
   - Optionally asks for a Brave API key
   - Automatically generates:
     - `.env` configuration
     - `package.json` with all dependencies
     - `main.js` from a pre-written template

2. **On future startups**:
   - Skips prompts and launches directly
   - Starts a local Express server
   - Lets ChatD connect to it for file search, file creation, reading, editing

3. **LLM responds to your questions**, always prioritizing your local data.

---

## 🔐 Privacy First

- ❌ No cloud dependencies
- ✅ Your files never leave your machine
- ✅ No data is shared unless you explicitly connect to online search via Brave API

---

## 📁 Features

| Feature             | Description |
|---------------------|-------------|
| 🔄 Auto-boot         | Runs automatically on Windows startup (via `.vbs` or Task Scheduler) |
| 📂 Folder Access     | Only the directories you allow are scanned |
| 💬 Natural Chat      | Use natural language to find files, content, and answers |
| ✍️ File Editor       | AI can modify and create files locally |
| 🔍 Search Fallback   | Optional Brave Search if nothing local is found |
| 🔧 Fully Offline     | Works even without internet if Brave key is not set |

---

## 🧠 Powered By

- [Ollama](https://ollama.com/) + Phi-3 / Llama3 / your preferred model
- [ChatD](https://github.com/modelcontext/chatd) for the conversational frontend
- Node.js for backend logic
