<?php

namespace App\Services;

use Spatie\PdfToText\Pdf;
use thiagoalessio\TesseractOCR\TesseractOCR;

class DocumentProcessor
{
    public function extractTextFromImage($imagePath)
    {
        try {
            return (new TesseractOCR($imagePath))
                ->run();
        } catch (\Exception $e) {
            return 'Error extracting text: '.$e->getMessage();
        }
    }

    public function extractTextFromPdf($pdfPath)
    {
        try {
            return (new Pdf)
                ->setPdf($pdfPath)
                ->text();
        } catch (\Exception $e) {
            return 'Error extracting text: '.$e->getMessage();
        }
    }
}
