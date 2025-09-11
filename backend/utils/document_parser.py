from io import BytesIO
from typing import Optional
from common.logger import logger
import docx
import PyPDF2


def parse_pdf(content: bytes) -> str:
    """解析PDF文件内容"""
    try:
        pdf_reader = PyPDF2.PdfReader(BytesIO(content))
        text = ""
        for page in pdf_reader.pages:
            text += page.extract_text() + "\n"
        return text
    except Exception as e:
        raise ValueError(f"PDF解析失败: {str(e)}")


def parse_docx(content: bytes) -> str:
    """解析DOCX文件内容"""
    try:
        doc = docx.Document(BytesIO(content))
        text = ""
        for paragraph in doc.paragraphs:
            text += paragraph.text + "\n"
        return text
    except Exception as e:
        raise ValueError(f"DOCX解析失败: {str(e)}")


def parse_document(file_content: bytes, file_extension: str) -> str:
    """根据文件扩展名解析文档内容"""
    if file_extension.lower() == ".pdf" or file_extension.lower() == "pdf":
        return parse_pdf(file_content)
    elif file_extension.lower() == ".docx" or file_extension.lower() == "docx":
        return parse_docx(file_content)
    else:
        try:
            return file_content.decode("utf-8")
        except Exception as e:
            logger.error(f"文件解析失败: {str(e)}")
            raise ValueError(f"不支持的文件格式: {file_extension}")
