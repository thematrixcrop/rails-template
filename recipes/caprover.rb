# frozen_string_literal: true

copy_forced "captain-definition"
template_forced "docker-compose.production.yml.tt", "docker-compose.production.yml"
