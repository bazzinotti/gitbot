class Score #< ActiveRecord::Base
  # log high score
  def scored(score)
    if score > self.high_score
      $redis.zadd("highscores", score, self.id)
    end
  end
  
  # table rank
  def rank
    $redis.zrevrank("highscores", self.id) + 1
  end
  
  # high score
  def high_score
    $redis.zscore("highscores", self.id).to_i
  end
  
  def self.top(table)
    $redis.zrevrange(table, 0, -1, :with_scores => true) # .map{|id| User.find(id)}
  end

  def self.top_n(table, n)
    $redis.zrevrange(table, 0, n-1, :with_scores => true) # .map{|id| User.find(id)}
  end
end