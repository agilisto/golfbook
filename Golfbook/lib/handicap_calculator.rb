class HandicapCalculator

  @@handicap_differentials = [
    {:handicap => -6, :range => [-55, -1000000]},
    {:handicap => -5, :range => [-45, -54]},
    {:handicap => -4, :range => [-35, -44]},
    {:handicap => -3, :range => [-25, -34]},
    {:handicap => -2, :range => [-15, -24]},
    {:handicap => -1, :range => [-5, -14]},
    {:handicap => 0, :range => [4, -4]},
    {:handicap => 1, :range => [5, 14]},
    {:handicap => 2, :range => [15, 24]},
    {:handicap => 3, :range => [25, 34]},
    {:handicap => 4, :range => [35, 44]},
    {:handicap => 5, :range => [45, 54]},
    {:handicap => 6, :range => [55, 64]},
    {:handicap => 7, :range => [65, 74]},
    {:handicap => 8, :range => [75, 84]},
    {:handicap => 9, :range => [85, 94]},
    {:handicap => 10, :range => [95, 104]},
    {:handicap => 11, :range => [105, 114]},
    {:handicap => 12, :range => [115, 124]},
    {:handicap => 13, :range => [125, 134]},
    {:handicap => 14, :range => [135, 144]},
    {:handicap => 15, :range => [145, 154]},
    {:handicap => 16, :range => [155, 164]},
    {:handicap => 17, :range => [165, 174]},
    {:handicap => 18, :range => [175, 184]},
    {:handicap => 19, :range => [185, 194]},
    {:handicap => 20, :range => [195, 204]},
    {:handicap => 21, :range => [205, 214]},
    {:handicap => 22, :range => [215, 224]},
    {:handicap => 23, :range => [225, 234]},
    {:handicap => 24, :range => [235, 244]},
    {:handicap => 25, :range => [245, 254]},
    {:handicap => 26, :range => [255, 264]},
    {:handicap => 27, :range => [265, 274]},
    {:handicap => 28, :range => [275, 284]},
    {:handicap => 29, :range => [285, 294]},
    {:handicap => 30, :range => [295, 304]},
    {:handicap => 31, :range => [305, 314]},
    {:handicap => 32, :range => [315, 324]},
    {:handicap => 33, :range => [325, 334]},
    {:handicap => 34, :range => [335, 344]},
    {:handicap => 35, :range => [345, 354]},
    {:handicap => 36, :range => [355, 1000000]}
  ]

  @@number_of_differentials_table = [
    {:number_of_differentials => 2, :number_of_rounds => [6,7]},
    {:number_of_differentials => 4, :number_of_rounds => [8,9]},
    {:number_of_differentials => 5, :number_of_rounds => [10,11]},
    {:number_of_differentials => 6, :number_of_rounds => [12,13]},
    {:number_of_differentials => 7, :number_of_rounds => [14,15]},
    {:number_of_differentials => 8, :number_of_rounds => [16,17]},
    {:number_of_differentials => 9, :number_of_rounds => [18,19]},
    {:number_of_differentials => 10, :number_of_rounds => [20,20]}
  ]

  def initialize
    
  end

  #currently we are using 2*9 holes to count as round - this is against the regulations - we should determine if a round is elligable before we sent it here...
  def self.handicap_for(rounds)
    raise "Please provide the last 5-20 rounds in the format [{:course_par => 72, :round_score => 82, :number_of_holes => 18},{},{}...{}]" if (rounds.size > 20 || rounds.blank?)
    raise "Number of holes must be 18 or 9" if rounds.detect{|x|(x[:number_of_holes] != 18) && (x[:number_of_holes] != 9)}
    #we are actually interested in the difference between the round_score and the course_par
    rounds = rounds.collect{|x|(x[:number_of_holes] == 18) ? (x[:round_score] - x[:course_par]) : (x[:round_score] - x[:course_par]) * 2}
    #we only use the smallest differentials
    rounds.sort!
    puts rounds.inspect
    #look up number of differentials to use from @@number_of_differentials_table
    diffs_to_use = @@number_of_differentials_table.detect{|x|fall_in_range(x[:number_of_rounds],rounds.size)}[:number_of_differentials]
    puts diffs_to_use
    #if less than 10, work out the average for the differs then * 10
    total_score = (diffs_to_use == 10) ? rounds[0..20].sum : (rounds[0..(diffs_to_use - 1)].sum / diffs_to_use)*10.0
    puts total_score
    #then, lookup that value in @@handicap_differentials and return the handicap    
    handicap = @@handicap_differentials.detect{|x|fall_in_range(x[:range],total_score)}[:handicap]
  end

  def self.fall_in_range(range, value)
    (range.min <= value) && (range.max >= value)
  end

end



