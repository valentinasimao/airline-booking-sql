"""
Builds the database in DuckDB and runs every analysis query.
Results are printed and saved as Markdown tables in ../results.

    pip install duckdb
    python scripts/run_all.py
"""
from pathlib import Path
import duckdb

ROOT = Path(__file__).resolve().parent.parent
RESULTS = ROOT / "results"
RESULTS.mkdir(exist_ok=True)
PREVIEW_ROWS = 15


def to_markdown(cols, rows):
    def fmt(v):
        if v is None:
            return ""
        if isinstance(v, float):
            return f"{v:,.2f}".rstrip("0").rstrip(".")
        return str(v)
    head = "| " + " | ".join(cols) + " |\n|" + "|".join("---" for _ in cols) + "|\n"
    return head + "".join("| " + " | ".join(fmt(v) for v in r) + " |\n" for r in rows)


def main():
    con = duckdb.connect()                      # in-memory database
    import os; os.chdir(ROOT)                   # CSV paths are relative to the repo root
    for f in ["sql/01_schema.sql", "sql/02_load_duckdb.sql", "sql/03_views.sql"]:
        con.execute((ROOT / f).read_text())

    for q in sorted((ROOT / "queries").glob("*.sql")):
        sql = q.read_text()
        title = next(l for l in sql.splitlines() if l.startswith("-- Q")).lstrip("- ").strip()
        cur = con.execute(sql)
        cols = [d[0] for d in cur.description]
        rows = cur.fetchall()
        md = f"# {title}\n\nQuery: [`queries/{q.name}`](../queries/{q.name}) · **{len(rows):,} rows** " \
             f"(first {min(PREVIEW_ROWS, len(rows))} shown)\n\n" + to_markdown(cols, rows[:PREVIEW_ROWS])
        (RESULTS / f"{q.stem}.md").write_text(md, encoding="utf-8")
        print(f"\n{title}  ->  {len(rows)} rows")
        print(to_markdown(cols, rows[:5]))


if __name__ == "__main__":
    main()
