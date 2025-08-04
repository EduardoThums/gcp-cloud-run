# 3.13.5
FROM cgr.dev/chainguard/python:latest-dev@sha256:b080419db9405e51ab87b394f6437b5ba2e93f45b9a119418f6f3189a3bf403f AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
# ENV PATH="/app/venv/bin:$PATH"

# 0.8.4
COPY --from=ghcr.io/astral-sh/uv@sha256:40775a79214294fb51d097c9117592f193bcfdfc634f4daa0e169ee965b10ef0 /uv /uvx /bin/

ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

COPY pyproject.toml uv.lock .

RUN uv sync --no-cache --no-dev --frozen --no-install-project

# 3.13.5
FROM cgr.dev/chainguard/python:latest@sha256:6f46ebeb893e87e4e4f13555ec792b4c82a396e4e16b6420f4b934789d0c4a16
# FROM cgr.dev/chainguard/python:latest-dev@sha256:b080419db9405e51ab87b394f6437b5ba2e93f45b9a119418f6f3189a3bf403f

WORKDIR /app

EXPOSE 8080

ENV PYTHONUNBUFFERED=1
ENV PATH="/app/.venv/bin:$PATH"
# ENV PYTHONPATH="/app/.venv"

COPY --from=builder /app/.venv /app/.venv
COPY app.py ./

ENTRYPOINT ["python"]
CMD ["-m", "flask", "run", "--host=0.0.0.0", "--port=8080"]
