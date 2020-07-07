# frozen_string_literal: true

Then('lever {lever} {should} be flipped') do |lever, should|
   is_flipped = page.evaluate_script(%[
                                     #{ game_vm_js }.buttonGroup.getByName("#{ lever }").switched;
   ])

   expect(is_flipped).to be(should)
end

Then('there should be {int} disc(s) on {peg}') do |n, peg_name|
   # for some reason this needs to be wrapped in a JS function or else headless chrome complains
   peg_discs = page.evaluate_script(%[
                     function() {
                        var vm = #{ game_vm_js };
                        var peg = vm.pegs.find(function(p){return p.name === "#{ peg_name }"});
                        return vm.getDiscs(peg).length;
                     }();
                       ])

   expect(peg_discs).to eq(n)
end

Then('the last click should be move number {int}') do |n|
   # sorting these seems to fix a possible race condition where the last one recorded is not
   # actually the last click (because it's clicking way faster than a human)
   clicks = @persisters[:click].clicks.to_a.sort_by(&:time)

   expect(clicks.last.move_number).to eq(n)
end

Then('the last click should be marked as complete') do
   repo = @persisters[:click]

   expect(repo.clicks.to_a.any?(&:complete)).to be true

   # puts 'clicks'
   # repo.clicks.to_a.each do |click|
   #    puts "#{ click.time.to_i } / #{ click.complete }"
   # end
   # puts "last: #{ @persisters[:click].last.time.to_i }"

   # sorting these seems to fix a possible race condition where the last one recorded is not
   # actually the last click (because it's clicking way faster than a human)
   clicks = @persisters[:click].clicks.to_a.sort_by(&:time)

   expect(clicks.last.complete).to be true
end
