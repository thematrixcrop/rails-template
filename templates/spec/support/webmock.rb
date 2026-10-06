# frozen_string_literal: true

# Specs never reach the network. Stub outbound clients in the example;
# WebMock is the backstop that turns a forgotten stub into a failure.
WebMock.disable_net_connect!(allow_localhost: true)
