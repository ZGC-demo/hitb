defmodule Block.P2pMessage do
  @moduledoc """
  p2p messaging protocol. Defines message options.
  """
  @update_block_chain "update_block_chain"
  @add_peer_request   "add_peer_request"
  @already_connected  "already_connected"
  @connection_error   "connection_error"
  @connection_success "successfully_connected"

  @latest_block       "latest_block"
  @sync_block         "sync_block"
  @sync_peer          "sync_peer"
  @all_accounts       "all_accounts"
  @all_blocks         "all_blocks"
  @all_transactions   "all_transactions"
  @other_sync         "other_sync"
  @sync_data          "sync_data"

  @add_block          "add_block"
  @add_accounts       "add_accounts"
  @add_transactions   "add_transactions"
  @add_peers          "add_peers"
  @add_other_sync     "add_other_sync"
  @add_other_data     "add_other_data"

  def update_block_chain, do: @update_block_chain
  def add_peer_request,   do: @add_peer_request
  def already_connected,  do: @already_connected
  def connection_error,   do: @connection_error
  def connection_success, do: @connection_success
  def latest_block,  do: @latest_block
  def sync_block,   do: @sync_block
  def sync_peer,   do: @sync_peer
  def all_accounts,   do: @all_accounts
  def all_blocks,   do: @all_blocks
  def all_transactions, do: @all_transactions
  def other_sync,   do: @other_sync
  def sync_data,   do: @sync_data
  def add_block,   do: @add_block
  def add_accounts,   do: @add_accounts
  def add_transactions, do: @add_transactions
  def add_peers,   do: @add_peers
  def add_other_sync,   do: @add_other_sync
  def add_other_data,   do: @add_other_data
end
