defmodule Block.P2pMessage do
  @moduledoc """
  p2p messaging protocol. Defines message options.
  """
  @latest_block     "latest_block"
  @all_accounts     "all_accounts"
  @all_blocks       "all_blocks"
  @all_transactions "all_transactions"
  @update_block_chain     "update_block_chain"
  @add_peer_request       "add_peer_request"
  @already_connected      "already_connected"
  @connection_error       "connection_error"
  @connection_success     "successfully_connected"
  @sync_block             "sync_block"
  @sync_peer              "sync_peer"

  def latest_block,   do: @latest_block
  def all_accounts,     do: @all_accounts
  def all_blocks,     do: @all_blocks
  def all_transactions, do: @all_transactions
  def update_block_chain,   do: @update_block_chain
  def add_peer_request,     do: @add_peer_request
  def already_connected,    do: @already_connected
  def connection_error,     do: @connection_error
  def connection_success,   do: @connection_success
  def sync_block,           do: @sync_block
  def sync_peer,            do: @sync_peer
end
