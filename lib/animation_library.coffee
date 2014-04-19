do (window) ->
  'use strict'

  # アプリ内で使ってるUIアニメーションはここに定義しておく
  class AnimationLibrary
    constructor: ->
      @config =
        modal:
          keyframe:
            "0%":
              translateY: "-35px"
              scaleY:     "0.8"
              opacity:    "0"
            "100%":
              translateY: "0px"
              scaleY:     "1"
              opacity:    "1"
          animation:
            duration:  "0.2s"
          origin: "-35px 0"
        showModal:
          name: "modal"
          keyframe: "modal.keyframe"
          origin: "modal.origin"
          animation: "modal.animation"
        hideModal:
          name: "modal"
          keyframe: "modal.keyframe"
          origin: "modal.origin"
          animation:
            dist: "modal.animation"
            direction: "reverse"

        menu:
          keyframe:
            "0%":
              scale:   "0.7"
              opacity: "0"
            "90%":
              scale:   "1.1"
            "100%":
              scale:   "1"
              opacity: "1"
          animation:
            duration: "0.15s"
        showMenu:
          name: "menu"
          keyframe: "menu.keyframe"
          animation: "menu.animation"
        hideMenu:
          name: "menu"
          keyframe: "menu.keyframe"
          animation:
            dist: "menu.animation"
            direction: "reverse"

        screen:
          keyframe:
            "0%":
              #translateY: "100%"
              scale: "0.9"
              opacity: "0"
            "100%":
              #translateY: "0"
              scale: "1"
              opacity: "1"
          animation:
            duration: "0.1s"
        showScreen:
          name: "screen"
          keyframe: "screen.keyframe"
          animation: "screen.animation"
        hideScreen:
          name: "screen"
          keyframe: "screen.keyframe"
          animation:
            dist: "screen.animation"
            direction: "reverse"

        accordion:
          keyframe:
            "0%":
              translateX: "100%"
              opacity: "0"
            "100%":
              translateX: "0"
              opacity: "1"
          animation:
            duration: "0.3s"
        showAccordion:
          name: "accordion"
          keyframe: "accordion.keyframe"
          animation: "accordion.animation"
        hideAccordion:
          name: "accordion"
          keyframe: "accordion.keyframe"
          animation:
            dist: "accordion.animation"
            direction: "reverse"

        runTicker:
          name: "ticker"
          animation:
            duration: "8s"
            delay: "1.5s"

    setup: (name, $el, callback) ->
      config = @config[name]

      # keyframeとかanimationとか共通化したい時もある
      dest = {}
      _.each ["keyframe", "animation", "origin"], (property) =>
        isStringDist = _.isString config[property]
        isExistDist = config[property]?.dist
        return unless isStringDist or isExistDist

        if isStringDist
          [_base, _prop] = config[property].split(".")
          dest[property] = @config[_base][_prop]
        else
          [_base, _prop] = config[property].dist.split(".")
          _.extend config[property], @config[_base][_prop]
          delete config[property].dist

      config = _.extend {}, config, dest,
        $el: $el
        endCallback: callback
      Util.KeyframeAnimation.setup config

    # TODO: setup系methodは自動でつくりたい
    # TODO: "modal:show"みたいな感じでconfigをいい感じにしたい
    setupShowModal: ($el, callback) -> @setup "showModal", $el, callback
    setupHideModal: ($el, callback) -> @setup "hideModal", $el, callback

    setupShowMenu: ($el, callback) -> @setup "showMenu", $el, callback
    setupHideMenu: ($el, callback) -> @setup "hideMenu", $el, callback

    setupShowScreen: ($el, callback) -> @setup "showScreen", $el, callback
    setupHideScreen: ($el, callback) -> @setup "hideScreen", $el, callback

    setupShowAccordion: ($el, callback) -> @setup "showAccordion", $el, callback
    setupHideAccordion: ($el, callback) -> @setup "hideAccordion", $el, callback

    setupRunTicker: ($el, callback) -> @setup "runTicker", $el, callback

  window.animationLibrary = new AnimationLibrary()

