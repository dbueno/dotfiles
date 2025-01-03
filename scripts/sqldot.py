import argparse
import sqlite3
import sys


def create_dot_file(filepath, table, source_col, dest_col):
    with sqlite3.connect(filepath) as conn:
        cursor = conn.cursor()

        query = f'SELECT "{source_col}", "{dest_col}" FROM "{table}"'

        try:
            cursor.execute(query)

            dot_file = sys.stdout
            dot_file.write("digraph G {\n")
            for row in cursor:
                source = row[0]
                dest = row[1]
                dot_file.write(f'    "{source}" -> "{dest}";\n')
            dot_file.write("}\n")

        except sqlite3.Error as e:
            print(f"An error occurred: {e}")


def main():
    parser = argparse.ArgumentParser(
        description="Generate a DOT file from a SQLite database."
    )
    parser.add_argument("filepath", type=str, help="The SQLite database file")
    parser.add_argument("table", type=str, help="The table containing the graph.")
    parser.add_argument("source_col", type=str, help="The source column name.")
    parser.add_argument("dest_col", type=str, help="The destination column name.")

    args = parser.parse_args()

    create_dot_file(args.filepath, args.table, args.source_col, args.dest_col)


if __name__ == "__main__":
    main()
