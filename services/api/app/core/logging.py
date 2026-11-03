import logging
import sys
from app.core.config import settings

def setup_logging() -> None:
    """
    Configures structured standard logging for the BuildMart API service.
    """
    log_level = logging.DEBUG if settings.DEBUG else logging.INFO
    log_format = "%(asctime)s [%(levelname)s] [%(name)s] %(message)s"

    logging.basicConfig(
        level=log_level,
        format=log_format,
        handlers=[logging.StreamHandler(sys.stdout)],
        force=True
    )

logger = logging.getLogger("buildmart")

