# PDF Parser Agent

## Overview
This project provides an AI-powered solution for parsing complex PDF files, specifically designed to extract structured data such as Haircut Schedules from CME-related documents. It leverages the `pydantic-ai` framework, Google Gemini models, and PyPDF2 to read, process, and extract information from multi-page, table-rich PDFs. The extracted data is returned in a structured JSON format, making it easy to integrate with other systems or workflows.

## Features
- Parses multi-page, complex PDFs with tables and sections.
- Focuses on extracting Haircut Schedule data (asset class, duration, value, etc.).
- Uses AI agents for iterative, high-accuracy extraction.
- REST API for easy integration and automation.

## How to Run


### 1. Install Dependencies
Make sure you have Python 3.8+ installed. Then, install the required packages:

```bash
pip install -r requirements.txt
```

### 2. Set Your Gemini API Key
Export your Gemini API key as an environment variable before running the agent or API:

```bash
export GEMINI_API_KEY={your_api_key_here}
```

### 3. Run the AI Agent Directly
You can run the agent directly to parse a PDF file and print the extracted data:

```bash
python agents/pydantic_ai_agent.py
```
- By default, it expects a file named `acceptable-collateral-futures-options-select-forwards.pdf` in the working directory. You can modify the filename in the script as needed.

### 4. Run the REST API
Start the FastAPI server to use the agent via a REST API:

```bash
python -m uvicorn api.rest_api:app --reload
```

- The API will be available at `http://localhost:8000`.
- Upload a PDF via the `/upload/` endpoint using a tool like [curl](https://curl.se/) or [Postman](https://www.postman.com/):

```bash
curl -X POST "http://localhost:8000/upload/" -F "file=@path_to_your_pdf.pdf"
```

### 4. Project Structure
- `agents/pydantic_ai_agent.py`: Main AI agent logic for PDF parsing.
- `api/rest_api.py`: FastAPI REST API for PDF upload and parsing.
- `knowledge/`: Example files for testing (PDF, CSV, TXT).
- `requirements.txt`: Python dependencies.

## Notes
- The agent is optimized for CME Haircut Schedule PDFs but can be adapted for similar structured documents.
- For best results, use high-quality, text-based PDFs (not scanned images).

## License
This project is for educational and research purposes. See individual file headers for more details.
