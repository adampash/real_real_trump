defmodule RealRealTrump.Watcher do
  use GenServer
  @trump_id "25073877"

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end


  def init(_) do
    Process.send(__MODULE__, :track, [])
    {:ok, []}
  end


  def handle_info(:track, state) do
    start_stream
    {:noreply, state}
  end

  defp start_stream do
    spawn_link(fn ->
      stream = ExTwitter.stream_filter([follow: @trump_id], :infinity)
      IO.inspect "Watching my trump"
      IO.puts "Is it Trump?"
      for tweet <- stream do
        tweet_if_trump(tweet)
      end
    end)
  end

  def tweet_if_trump(tweet) do
    if is_trump?(tweet) do
      IO.inspect tweet.retweeted_status
      IO.puts "IT TRUMP"
      # ExTwitter.retweet(tweet.id)
      # tweet_text = "#{random_boast} https://twitter.com/realDonaldTrump/status/#{tweet.id}"
      # ExTwitter.update(tweet_text)
      ExTwitter.update(tweet.text)
    else
      IO.puts "IT NOT TRUMP"
    end
  end

  def is_trump?(tweet) do
    tweet.user.id_str == @trump_id && String.contains?(String.downcase(tweet.source), "android") && is_nil(tweet.retweeted_status)
  end

end
