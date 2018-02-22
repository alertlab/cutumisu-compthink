ko.components.register('hanoi-game', {
   template: '<div class="game-container"></div>\
              <header>Towers of Hanoi</header>',

   /**
    */
   viewModel: function (params) {
      var self = this;

      var gameWidth = 800;
      var gameHeight = 600;

      self.preload = function () {
         self.game.load.image('disc_normal', '/assets/images/games/disc_unselected.png');
         self.game.load.image('disc_selected', '/assets/images/games/disc_selected.png');
         self.game.load.image('peg', '/assets/images/games/peg.png');
      };

      var numDiscs = 3;
      var discPadding = 5; // px

      self.discs = [];
      self.pegs = [];

      self.selectedDisc = null;

      self.create = function () {
         self.game.scale.scaleMode = Phaser.ScaleManager.SHOW_ALL;
         self.game.scale.pageAlignHorizontally = true;
         self.game.scale.pageAlignVertically = true;
         self.game.scale.refresh();

         var pegY = gameHeight / 2;

         ['A', 'B', 'C'].forEach(function (pegName, i) {
            var peg = self.game.add.sprite(gameWidth / 4 * (i + 1), pegY, 'peg');

            peg.anchor.setTo(0.5);
            peg.scale.setTo(0.1, 0.1);
            peg.name = i;
            peg.inputEnabled = true;
            peg.events.onInputDown.add(self.pegClick, this);

            self.pegs.push(peg);
         });

         for (var discNumber = 0; discNumber < numDiscs; discNumber++) {
            var disc;

            disc = self.game.add.sprite(0, 0, 'disc_normal');
            disc.name = discNumber;
            disc.anchor.setTo(0.5);
            disc.scale.setTo(0.15 - 0.125 * discNumber / numDiscs, 0.1);

            self.moveTo(disc, self.pegs[0]);

            disc.inputEnabled = true;
            disc.events.onInputDown.add(self.discClick, this);

            self.discs.push(disc);
         }

         self.moves = 0;

         self.statusLabel = self.game.add.text(self.game.world.centerX, 50, "Moves: " + self.moves, {
            fill: '#ffffff'
         });
         self.statusLabel.anchor.x = Math.round(self.statusLabel.width * 0.5) / self.statusLabel.width;
      };

      self.game = new Phaser.Game(gameWidth, gameHeight, Phaser.CANVAS, document.querySelector('hanoi-game .game-container'), {
         preload: self.preload,
         create: self.create
      });

      self.getDiscs = function (peg) {
         return self.discs.filter(function (disc) {
            return disc.peg === peg;
         });
      };

      self.getTopDisc = function (peg) {
         var filteredDiscs = self.getDiscs(peg);

         return filteredDiscs[filteredDiscs.length - 1];
      };

      self.discClick = function (disc) {
         if (self.isComplete() || !disc)
            return;

         if (self.selectedDisc)
            self.selectedDisc.loadTexture('disc_normal');

         if (self.getTopDisc(disc.peg) === disc) {
            self.selectedDisc = disc;
            disc.loadTexture('disc_selected');
         }
      };

      self.moveTo = function (disc, peg) {
         disc.x = peg.x;
         disc.y = peg.y + peg.height / 2 - (disc.height + discPadding) * (self.getDiscs(peg).length + 1);

         disc.peg = peg;

         self.moves++;
      };

      self.isComplete = function () {
         // game objective is complete if moved all to any *but* starting peg
         return self.pegs.slice(1).some(function (peg) {
            return self.getDiscs(peg).length === numDiscs;
         });
      };

      self.pegClick = function (peg) {
         var topDisc;

         if (self.isComplete())
            return;

         topDisc = self.getTopDisc(peg);

         if (!self.selectedDisc) {
            // treat peg clicks (when nothing selected) as implicit selection of top disc for ease of use
            self.discClick(topDisc);
         } else {
            if (!topDisc || self.selectedDisc.width < topDisc.width)
               self.moveTo(self.selectedDisc, peg);

            self.selectedDisc.loadTexture('disc_normal');
            self.selectedDisc = null;
         }

         if (self.isComplete())
            self.statusLabel.text = "You finished in " + self.moves + " moves!";
         else
            self.statusLabel.text = "Moves: " + self.moves;

         ajax('post', '/games/logging/record_click', ko.toJSON({
            complete: self.isComplete(),
            item: peg.name,
            move: self.moves
         }));
      }
   }
});