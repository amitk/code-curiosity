namespace :round do
  desc "Creat next round"
  task :next => :environment do |t, args|
    round = Round.opened
    round.round_close
    opened_round = Round.opened
    per_batch = 1000

    0.step(User.count, per_batch) do |offset|
      User.limit(per_batch).skip(offset).each do |user|
        user.subscribe_to_round(opened_round)
      end
    end
  end

  desc "Update Round scores" 
  task :update_scores,  [:round] => :environment do |t, args|
     subscriptions = Subscription.all
     # subscriptions = Round.opened.subscriptions

     Subscription.all.each do |s|
       s.set(points: s.round.commits.where(user: s.user).sum(:auto_score))
     end 
  end
end