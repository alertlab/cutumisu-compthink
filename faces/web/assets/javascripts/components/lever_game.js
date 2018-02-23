ko.components.register('lever-game', {
   template: '<div class="game-container"></div>\
              <header>Lever Puzzle</header>',

   /**
    */
   viewModel: function (params) {
      var self = this;

      var expected, shuffleExpected;

      var gameWidth = params['width'] || explode('Must provide game width in params');
      var gameHeight = params['height'] || explode('Must provide game height in params');

      var buttonSize = 82;

      self.moves = 0;
      shuffleExpected = true;

      expected = eatCookie('compthink.game.expected');

      if (expected) {
         expected = decodeURIComponent(expected).split(',');
         shuffleExpected = false;
      } else
         expected = ['A', 'B', 'C', 'D'];

      self.preload = function () {
         self.game.load.spritesheet('button', '/assets/images/games/button.png', buttonSize, buttonSize, 2);
      };

      self.create = function () {
         var game, buttonX, buttonY, button, spaceSize;

         game = self.game;

         game.scale.scaleMode = Phaser.ScaleManager.SHOW_ALL;
         game.scale.pageAlignHorizontally = true;
         game.scale.pageAlignVertically = true;
         game.scale.refresh();

         game.stage.backgroundColor = "#444444";

         self.buttonGroup = this.game.add.group();

         spaceSize = (gameWidth - (expected.length * buttonSize)) / (expected.length + 1);
         buttonY = gameHeight / 3;

         expected.forEach(function (leverName, i) {
            buttonX = spaceSize * (i + 1) + buttonSize * i;
            button = game.add.sprite(buttonX, buttonY, 'button');
            button.inputEnabled = true;
            button.events.onInputDown.add(self.buttonClick, this);
            button.name = leverName;
            button.switched = false;
            button.switch = function () {
               this.switched = true;
               this.loadTexture('button', 1);
            };
            button.reset = function () {
               this.switched = false;
               this.loadTexture('button', 0);
            };
            self.buttonGroup.add(button);
         });

         self.text = game.add.text(game.world.centerX, 50, 'Moves: ', {fill: '#ffffff', fontSize: '18px'});
         self.text.anchor.x = Math.round(self.text.width * 0.5) / self.text.width;
         self.text.text = "Moves: " + self.moves;

         if (shuffleExpected)
            self.shuffle(expected);
         console.log('Expecting:' + expected)
      };

      self.buttonClick = function (button, inputDevice) {
         var prereqButton, finalButton;

         finalButton = self.buttonGroup.getByName(expected[expected.length - 1]);
         prereqButton = self.buttonGroup.getByName(expected[expected.indexOf(button.name) - 1]);

         // intentionally ignoring any clicks after they're done
         if (finalButton.switched)
            return;

         self.moves++;
         self.text.text = "Moves: " + self.moves;

         if (!prereqButton || prereqButton.switched) {
            button.switch();

            if (button === finalButton)
               self.text.text = "You finished in " + self.moves + " moves!";
         } else {
            self.buttonGroup.children.forEach(function (b) {
               b.reset();
            });
         }

         ajax('post', '/games/logging/record_click', ko.toJSON({
            puzzle: 'levers',
            expected: expected,
            complete: finalButton.switched,
            target: button.name,
            move_number: self.moves
         }));
      };

      self.game = new Phaser.Game(gameWidth, gameHeight, Phaser.AUTO, document.querySelector('lever-game .game-container'), {
         preload: self.preload,
         create: self.create
      });

      self.shuffle = function (array) {
         var i = 0
            , j = 0
            , temp = null;

         for (i = array.length - 1; i > 0; i -= 1) {
            j = Math.floor(Math.random() * (i + 1));
            temp = array[i];
            array[i] = array[j];
            array[j] = temp;
         }
      }
   }
});