ko.components.register('hanoi-game', {
   template: '<div class="game-meta-container">\
                 <div class="game-container"></div>\
              </div>\
              <dialog-confirm params="title: \'Finished\', visible: returnPrompt, actions: {}" class="return-prompt">\
                  <p>Great Success!</p>\
                  <p><a href="/games">Back To Game list</a></p>\
              </dialog-confirm>',

   /**
    */
   viewModel: function (params) {
      var self = this;

      self.returnPrompt = ko.observable(false);

      var gameWidth = params['width'] || explode('Must provide game width in params');
      var gameHeight = params['height'] || explode('Must provide game height in params');

      self.preload = function () {
         self.game.load.image('disc_normal', window.appData.imagePaths.disc_normal);
         self.game.load.image('disc_selected', window.appData.imagePaths.disc_selected);
         self.game.load.image('peg', window.appData.imagePaths.peg);
      };

      var numDiscs = params['discs'] || 3;
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
            peg.name = pegName;
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

         if (self.isComplete()) {
            self.statusLabel.text = "You finished in " + self.moves + " moves!";
            self.returnPrompt(true);
         } else
            self.statusLabel.text = "Moves: " + self.moves;

         TenjinComms.ajax('/games/logging/record-click', {
            data: {
               puzzle: 'hanoi',
               complete: self.isComplete(),
               target: peg.name,
               move_number: self.moves
            }
         });
      }
   }
});
