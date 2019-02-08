# frozen_string_literal: true

Then('lever {lever} {should} be flipped') do |lever, should|
   is_flipped = page.evaluate_script(%[
                                     #{ game_vm_js }.buttonGroup.getByName("#{ lever }").switched;
   ])

   expect(is_flipped).to be(should)
end

Then('there should be {int} disc(s) on {peg}') do |n, peg_name|
   peg_discs = page.evaluate_script(%[
                        var vm = #{ game_vm_js };
                        var peg = vm.pegs.find(function(p){return p.name === "#{ peg_name }"});
                        vm.getDiscs(peg).length;
                       ])

   expect(peg_discs).to eq(n)
end

Then('the last click should be move number {int}') do |n|
   expect(@persisters[:click].last.move_number).to eq(n)
end

Then('the last click should be marked as complete') do
   repo = @persisters[:click]

   expect(repo.clicks.to_a.any?(&:complete)).to be true

   puts repo.clicks.to_a.collect do |click|
      "#{ click.time.to_i } / #{ click.complete }"
   end

   expect(@persisters[:click].last.complete).to be true
end
