class ScoresController < ApplicationController
  def index
    @game = params[:g].to_s
    n = params[:n].to_i
    table = "#{@game}:highscores"
    @scores = n ? Score.top_n(table, n) : Score.top(table)
  end
end
