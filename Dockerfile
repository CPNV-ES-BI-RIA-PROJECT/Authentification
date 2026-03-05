FROM ruby:3.4-slim AS builder

ENV BUNDLE_WITHOUT="development:test" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_FROZEN="1"

WORKDIR /app

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./

RUN gem install bundler:2.6.9 \
    && bundle install \
    && bundle clean --force

FROM ruby:3.4-slim

ENV BUNDLE_WITHOUT="development:test" \
    BUNDLE_PATH="/usr/local/bundle" \
    PORT="4567" \
    AWS_REGION="us-east-1" \
    JWT_EXPIRATION_TIME="3600"

ENV JWT_SECRET_KEY="" \
    AWS_ACCESS_KEY_ID="" \
    AWS_SECRET_ACCESS_KEY=""

WORKDIR /app

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY Gemfile Gemfile.lock ./
COPY src ./src
COPY storages ./storages

RUN useradd --no-create-home appuser \
    && chown -R appuser:appuser /app /usr/local/bundle

USER appuser

EXPOSE 4567
VOLUME ["/app/storages"]

# Pass sensitive values at runtime, e.g.:
# docker run --env-file .env -p 4567:4567 <image>
CMD ["sh", "-c", "bundle exec ruby src/http/start.rb -o 0.0.0.0 -p ${PORT}"]
