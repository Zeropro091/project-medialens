import mammoth from 'mammoth';
import * as pdfjsLib from 'pdfjs-dist';

// Configure the worker for pdfjs
pdfjsLib.GlobalWorkerOptions.workerSrc = `//cdnjs.cloudflare.com/ajax/libs/pdf.js/${pdfjsLib.version}/pdf.worker.min.mjs`;

export async function parseDocument(file: File): Promise<string> {
  const arrayBuffer = await file.arrayBuffer();

  if (file.name.endsWith('.docx')) {
    const result = await mammoth.extractRawText({ arrayBuffer });
    return result.value;
  } else if (file.name.endsWith('.pdf')) {
    const pdf = await pdfjsLib.getDocument({ data: arrayBuffer }).promise;
    let fullText = '';
    
    for (let i = 1; i <= pdf.numPages; i++) {
        const page = await pdf.getPage(i);
        const textContent = await page.getTextContent();
        const pageText = textContent.items.map((item: any) => item.str).join(' ');
        fullText += pageText + '\n\n';
    }
    
    return fullText;
  } else if (file.name.endsWith('.txt') || file.name.endsWith('.md')) {
    return await file.text();
  }

  throw new Error('Unsupported file format. Please upload .pdf, .docx, .txt, or .md');
}
