# Run `just` to list the recipes.

default:
    @just --list

# Compile the paper to paper/main.pdf
paper:
    typst compile paper/main.typ paper/main.pdf

# Recompile the paper on every save
watch:
    typst watch paper/main.typ paper/main.pdf

# Install the experiment dependencies
setup:
    cd experiments && uv sync

# Run the evaluation
eval *args:
    cd experiments && uv run python -m src.run {{args}}

# Remove the compiled PDF
clean:
    rm -f paper/main.pdf

# Self-check of the metrics and parsers (no GPU needed)
test:
    cd experiments && python3 -m tests.test_evaluate
