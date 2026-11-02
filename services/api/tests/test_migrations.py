import os
import tempfile
import pytest
from alembic.config import Config
from alembic import command
from sqlalchemy import create_engine, inspect

@pytest.mark.filterwarnings("ignore::DeprecationWarning")
def test_alembic_upgrade_and_downgrade():
    """
    Validates that Alembic migrations run cleanly to head and can be fully rolled back to base.
    Fulfills Rule 7: Database migrations with tested rollback plan.
    """
    with tempfile.TemporaryDirectory() as tmp_dir:
        test_db_path = os.path.join(tmp_dir, "test_migration.db")
        # Standard sync sqlite url for inspecting schema with sync engine
        sync_url = f"sqlite:///{test_db_path}"
        async_url = f"sqlite+aiosqlite:///{test_db_path}"

        alembic_ini_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "alembic.ini"))
        assert os.path.exists(alembic_ini_path), f"alembic.ini not found at {alembic_ini_path}"

        alembic_cfg = Config(alembic_ini_path)
        alembic_cfg.set_main_option("sqlalchemy.url", async_url)

        # 1. Run upgrade head
        command.upgrade(alembic_cfg, "head")

        # 2. Inspect created tables
        engine = create_engine(sync_url)
        inspector = inspect(engine)
        tables = set(inspector.get_table_names())
        
        expected_tables = {
            "users",
            "shops",
            "categories",
            "brands",
            "products",
            "cart_items",
            "orders",
            "order_items",
            "banners",
            "quote_requests",
            "webhook_events",
            "alembic_version"
        }
        assert expected_tables.issubset(tables), f"Missing tables in migration: {expected_tables - tables}"

        # 3. Test rollback (downgrade base)
        command.downgrade(alembic_cfg, "base")

        # 4. Verify all application tables were dropped cleanly
        inspector_post = inspect(engine)
        remaining_tables = set(inspector_post.get_table_names())
        # alembic_version might remain or be empty, but application tables should be gone
        app_tables_remaining = remaining_tables - {"alembic_version"}
        assert len(app_tables_remaining) == 0, f"Tables not dropped during rollback: {app_tables_remaining}"
        engine.dispose()

