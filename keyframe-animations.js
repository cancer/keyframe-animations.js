(function() {
  (function(window) {
    'use strict';
    return window.CSSProperty = {
      animationEnd: "webkitAnimationEnd animationEnd animationend",
      addVendorPrefix: function(rules, option) {
        var isNeed, needPrefix, prefixed;
        needPrefix = [/^transform/, /^transition/, /^animation/, /^border.*Radius$/];
        isNeed = function(prop) {
          return _.some(needPrefix, function(exp) {
            return exp.test(prop);
          });
        };
        prefixed = _.clone(rules);
        _.each(rules, function(value, key) {
          if (isNeed(key)) {
            return prefixed["Webkit" + (_.string.capitalize(key))] = value;
          }
        });
        if (option != null ? option.dasherize : void 0) {
          return CSSProperty.toDasherizeKey(prefixed);
        }
        return prefixed;
      },
      toAnimationProperty: function(rules, option) {
        var fullName, prefixed;
        fullName = _.map(_.keys(rules), function(key) {
          return "animation" + (_.string.capitalize(key));
        });
        prefixed = _.object(fullName, _.values(rules));
        return CSSProperty.addVendorPrefix(prefixed, option);
      },
      toTransformFunction: function(rules) {
        var functionList, isTransform, transforms, _ref, _rules;
        functionList = [/^matrix/, /^translate/, /^scale/, /^rotate/, /^skew/, /perspective/];
        isTransform = function(name) {
          return _.some(functionList, function(exp) {
            return exp.test(name);
          });
        };
        transforms = ((_ref = rules.transform) != null ? _ref.split(" ") : void 0) || [];
        _rules = _.clone(rules);
        _.each(_rules, function(val, key, rules) {
          if (!isTransform(key)) {
            return;
          }
          transforms.push("" + key + "(" + val + ")");
          return delete rules[key];
        });
        _rules.transform = transforms.join(" ");
        return _rules;
      },
      toDasherizeKey: function(obj) {
        var dasherizeKeys;
        dasherizeKeys = _.map(_.keys(obj), function(val) {
          return _.string.dasherize(val);
        });
        return _.object(dasherizeKeys, _.values(obj));
      }
    };
  })(window);

}).call(this);

(function() {
  (function(window) {
    'use strict';
    var KeyframeAnimation;
    KeyframeAnimation = (function() {
      var animationEnd, cssProperty, defaultAnimationProperty, defaultTransformOrigin, kKeyframeUndefinedError, kTargetElementsUndefinedError;

      function KeyframeAnimation() {}

      cssProperty = window.CSSProperty;

      animationEnd = cssProperty.animationEnd;

      kKeyframeUndefinedError = "ReferrenceError: Property `keyframe` is undefined";

      kTargetElementsUndefinedError = "ReferrenceError: Target elements are undefined";

      defaultAnimationProperty = {
        duration: "0s",
        fillMode: "both",
        timingFunction: "linear",
        iterationCount: "1",
        delay: "0s",
        direction: "normal",
        playState: "running"
      };

      defaultTransformOrigin = {
        transformOrigin: "50% 50% 0"
      };

      KeyframeAnimation.prototype.get = function(name) {
        return CSSAnimations.get(name);
      };

      KeyframeAnimation.prototype.getDynamicSheet = function() {
        return CSSAnimations.getDynamicSheet();
      };

      KeyframeAnimation.prototype.create = function(name, frames) {
        return CSSAnimations.create(name, frames);
      };

      KeyframeAnimation.prototype.remove = function(name) {
        return CSSAnimations.remove(name);
      };

      KeyframeAnimation.prototype.setup = function(config) {
        var keyframe;
        this.config = config;
        if (this.isReverse()) {
          this.config.name += "Reverse";
        }
        if (!((this.config.keyframe != null) || ((keyframe = this.get(this.config.name)) != null))) {
          throw kKeyframeUndefinedError;
        }
        return {
          config: this.config,
          keyframe: keyframe || this.createKeyframes(),
          animate: this.setupAnimate(),
          freeze: (function(_this) {
            return function(option) {
              var callback, invoke;
              _this.stopAnimation((option != null ? option.$el : void 0) || _this.config.$el);
              callback = _this.config.endCallback;
              invoke = (callback != null) && (option != null) ? !!option.invoke : false;
              return invoke && callback.call(_this.config.$el);
            };
          })(this)
        };
      };

      KeyframeAnimation.prototype.isReverse = function() {
        return Util.Platform.isGoogle() && this.config.animation.direction === "reverse";
      };

      KeyframeAnimation.prototype.createKeyframes = function(hoge) {
        var keyframe, name;
        name = this.config.name;
        keyframe = this.isReverse() ? this.reverseKeyframe(this.config.keyframe) : _.clone(this.config.keyframe);
        _.each(keyframe, function(rules, keyText, keyframe) {
          rules = cssProperty.toTransformFunction(rules);
          return keyframe[keyText] = cssProperty.addVendorPrefix(rules, {
            dasherize: true
          });
        });
        if (name != null) {
          return this.create(name, keyframe);
        } else {
          return this.create(keyframe);
        }
      };

      KeyframeAnimation.prototype.reverseKeyframe = function(keyframe) {
        var keyText, reverseKeyText, reverseKeyframe, reverseValue;
        keyText = _.keys(keyframe);
        reverseKeyText = _.clone(keyText).reverse();
        reverseValue = _.map(reverseKeyText, function(key) {
          return keyframe[key];
        });
        return reverseKeyframe = _.object(keyText, reverseValue);
      };

      KeyframeAnimation.prototype.stopAnimation = function($el) {
        return $el.attr("style", this._defaultStyle).off(animationEnd);
      };

      KeyframeAnimation.prototype.setupAnimate = function() {
        var animate, animations, specificParams, transformOrigin;
        specificParams = {
          name: this.config.name,
          direction: this.getDirection(this.config.animation.direction)
        };
        animations = _.extend({}, defaultAnimationProperty, this.config.animation, specificParams);
        animations = cssProperty.toAnimationProperty(animations, {
          dasherize: true
        });
        transformOrigin = _.defaults({
          transformOrigin: this.config.origin
        }, defaultTransformOrigin);
        transformOrigin = cssProperty.addVendorPrefix(transformOrigin, {
          dasherize: true
        });
        return animate = (function(_this) {
          return function($el, additionalAnimations, callback) {
            var additional;
            if ($el == null) {
              $el = _this.config.$el;
            }
            if (additionalAnimations == null) {
              additionalAnimations = {};
            }
            if (callback == null) {
              callback = _this.config.endCallback;
            }
            if ($el == null) {
              throw kTargetElementsUndefinedError;
            }
            if (_.isFunction(additionalAnimations)) {
              callback = additionalAnimations;
              additionalAnimations = void 0;
            }
            additional = cssProperty.toAnimationProperty(additionalAnimations, {
              dasherize: true
            });
            animations = _.extend({}, animations, additional);
            _this._defaultStyle = $el.attr("style") || "";
            if (_this._defaultStyle instanceof CSSStyleDeclaration) {
              _this._defaultStyle = "";
            }
            $el.on(animationEnd, function() {
              _this.stopAnimation($el);
              return callback && callback.call($el[0], $el);
            });
            return $el.css(_.extend({}, animations, transformOrigin));
          };
        })(this);
      };

      KeyframeAnimation.prototype.getDirection = function(direction) {
        if (!direction) {
          return defaultAnimationProperty.direction;
        }
        if (this.isReverse()) {
          return "normal";
        }
        return direction;
      };

      KeyframeAnimation.prototype.setupFreeze = function() {
        var freeze;
        return freeze = function(option) {
          var invoke;
          this.stopAnimation(this.config.$el);
          invoke = (typeof callback !== "undefined" && callback !== null) && (option != null) ? option.invoke : false;
          return invoke && callback.call(this.config.$el);
        };
      };

      return KeyframeAnimation;

    })();
    return window.keyframeAnimation = new KeyframeAnimation();
  })(window);

}).call(this);
