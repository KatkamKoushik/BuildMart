import io
import time

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.models.models import QuoteRequest
from app.schemas.schemas import QuoteRequestCreate, QuoteRequestResponse

router = APIRouter(prefix="/quotes", tags=["Quotes"])

@router.post("", response_model=QuoteRequestResponse)
async def create_quote_request(
    payload: QuoteRequestCreate,
    db: AsyncSession = Depends(get_db)  # noqa: B008
):
    timestamp = int(time.time())
    quote_number = f"QT-{timestamp}"

    # Calculate rough estimate if products provided
    estimated_total = sum(item.quantity * 500 for item in payload.items)

    items_data = [item.model_dump() for item in payload.items]

    quote = QuoteRequest(
        quote_number=quote_number,
        customer_name=payload.customer_name,
        email=payload.email,
        phone=payload.phone,
        project_name=payload.project_name or "General Construction",
        delivery_pincode=payload.delivery_pincode,
        items=items_data,
        estimated_total=float(estimated_total),
        status="submitted"
    )
    db.add(quote)
    await db.commit()
    await db.refresh(quote)
    return quote

@router.get("/{quote_id}/pdf")
async def download_quote_pdf(
    quote_id: str,
    db: AsyncSession = Depends(get_db)  # noqa: B008
):
    result = await db.execute(
        select(QuoteRequest).where(
            (QuoteRequest.id == quote_id) | (QuoteRequest.quote_number == quote_id)
        )
    )
    quote = result.scalars().first()
    if not quote:
        raise HTTPException(status_code=404, detail="Quote request not found")

    # Generate PDF using ReportLab
    try:
        from reportlab.lib import colors
        from reportlab.lib.pagesizes import letter
        from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
        from reportlab.platypus import (
            Paragraph,
            SimpleDocTemplate,
            Spacer,
            Table,
            TableStyle,
        )

        buffer = io.BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=letter, rightMargin=36, leftMargin=36, topMargin=36, bottomMargin=36)
        elements = []
        styles = getSampleStyleSheet()

        title_style = ParagraphStyle(
            'TitleStyle',
            parent=styles['Heading1'],
            fontSize=22,
            textColor=colors.HexColor('#0B1527'),
            spaceAfter=10
        )
        subtitle_style = ParagraphStyle(
            'SubtitleStyle',
            parent=styles['Normal'],
            fontSize=11,
            textColor=colors.HexColor('#475569'),
            spaceAfter=20
        )

        elements.append(Paragraph("BUILDMART — MATERIAL ESTIMATE QUOTE", title_style))
        elements.append(Paragraph(f"Quote Ref: <b>{quote.quote_number}</b> | Project: {quote.project_name or 'Standard'}", subtitle_style))
        elements.append(Paragraph(f"<b>Customer:</b> {quote.customer_name} ({quote.email}) | <b>Phone:</b> {quote.phone}", styles['Normal']))
        elements.append(Paragraph(f"<b>Delivery Pincode:</b> {quote.delivery_pincode}", styles['Normal']))
        elements.append(Spacer(1, 15))

        # Items Table
        data = [["#", "Item Description", "Unit", "Quantity"]]
        for i, itm in enumerate(quote.items or [], 1):
            data.append([
                str(i),
                itm.get("title", "Item"),
                itm.get("unit", "units"),
                str(itm.get("quantity", 1))
            ])

        table = Table(data, colWidths=[30, 300, 80, 80])
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#0B1527')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 8),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#CBD5E1')),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#F8FAFC')]),
        ]))
        elements.append(table)

        elements.append(Spacer(1, 20))
        elements.append(Paragraph("<i>Note: This quotation is an estimate generated via BuildMart. Final rates are subject to delivery site verification.</i>", styles['Italic']))

        doc.build(elements)
        buffer.seek(0)
        pdf_bytes = buffer.getvalue()

        return Response(
            content=pdf_bytes,
            media_type="application/pdf",
            headers={"Content-Disposition": f"attachment; filename=quote_{quote.quote_number}.pdf"}
        )
    except Exception as e:  # noqa: BLE001
        raise HTTPException(status_code=500, detail=f"Failed to generate PDF: {e!s}")
