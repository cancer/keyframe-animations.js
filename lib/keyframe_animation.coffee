do (window) ->
  'use strict'

  # css-animation.jsをラップしていい感じにする
  class KeyframeAnimation
    cssProperty = window.CSSProperty
    animationEnd = cssProperty.animationEnd
    kKeyframeUndefinedError = "ReferrenceError: Property `keyframe` is undefined"
    kTargetElementsUndefinedError = "ReferrenceError: Target elements are undefined"
    # CSSAnimationのプロパティたち
    # via. http://www.w3.org/TR/css3-animations/#animation-play-state-property
    defaultAnimationProperty =
      duration:       "0s"
      fillMode:       "both"
      timingFunction: "linear"
      iterationCount: "1"
      delay:          "0s"
      direction:      "normal"
      playState:      "running"
    defaultTransformOrigin =
      transformOrigin: "50% 50% 0"

    get:            (name) -> CSSAnimations.get(name)
    getDynamicSheet:    () -> CSSAnimations.getDynamicSheet()
    create: (name, frames) -> CSSAnimations.create(name, frames)
    remove:         (name) -> CSSAnimations.remove(name)

    # keyframeAnimationを作っていい感じにする
    # config
    #   name:        keyframeAnimationの名前. デフォルトはCSSAnimationsがつける
    #   keyframe:    keyframe. VendorPrefixはいらない. プロパティはLowerCamelで(必須)
    #   animatio:   animationとしてstyleに設定する値. プロパティは`animation-`を取ってLowerCamelで
    #   $el:         animationさせる要素(必須. animate()の引数としての指定も可)
    #   endCallback: animationEndで呼ばれる関数(animate()の引数としての指定も可)
    setup: (@config) ->
      @config.name += "Reverse" if @isReverse()
      unless @config.keyframe? or (keyframe = @get @config.name)?
        throw kKeyframeUndefinedError

      return {
        config:   @config
        keyframe: keyframe || @createKeyframes()
        animate:  @setupAnimate()
        freeze:   (option) =>
          @stopAnimation option?.$el || @config.$el
          callback = @config.endCallback
          invoke = if callback? and option? then !!option.invoke else false
          invoke && callback.call @config.$el
      }

    isReverse: ->
      Util.Platform.isGoogle() and @config.animation.direction is "reverse"

    createKeyframes: (hoge) ->
      name = @config.name

      keyframe = if @isReverse() then @reverseKeyframe(@config.keyframe) else _.clone @config.keyframe

      # keyframeをいじる
      _.each keyframe, (rules, keyText, keyframe) ->
        rules = cssProperty.toTransformFunction rules
        keyframe[keyText] = cssProperty.addVendorPrefix rules, dasherize: true

      if name? then @create(name, keyframe) else @create(keyframe)

    reverseKeyframe: (keyframe) ->
      keyText = _.keys keyframe
      reverseKeyText = _.clone(keyText).reverse()
      reverseValue = _.map reverseKeyText, (key) -> keyframe[key]
      reverseKeyframe = _.object keyText, reverseValue

    stopAnimation: ($el) ->
      $el
        .attr "style", @_defaultStyle
        .off animationEnd

    setupAnimate: ->
      # config.animationより優先されるパラメーター
      specificParams =
        name : @config.name
        direction: @getDirection @config.animation.direction
      animations = _.extend {}, defaultAnimationProperty, @config.animation, specificParams
      animations = cssProperty.toAnimationProperty animations, dasherize: true
      transformOrigin = _.defaults transformOrigin: @config.origin, defaultTransformOrigin
      transformOrigin = cssProperty.addVendorPrefix transformOrigin, dasherize: true

      # param
      #   $el:       animationさせる要素
      #   animation: animationとしてstyleに設定する値(keyframe.configを上書き・追加)
      #   callback:  animationEndで呼ばれる関数
      animate = ($el = @config.$el, additionalAnimations = {}, callback = @config.endCallback) =>
        unless $el?
          throw kTargetElementsUndefinedError

        if _.isFunction additionalAnimations
          callback = additionalAnimations
          additionalAnimations = undefined

        additional = cssProperty.toAnimationProperty additionalAnimations, dasherize: true
        animations = _.extend {}, animations, additional
        @_defaultStyle = $el.attr("style") || ""
        # zeptoが余計なことするので
        @_defaultStyle = "" if @_defaultStyle instanceof CSSStyleDeclaration
        $el.on animationEnd, =>
          @stopAnimation $el
          callback && callback.call $el[0], $el

        $el.css _.extend {}, animations, transformOrigin

    # animation-directionの値を決める
    #   isReverseならkeyframeを既に反転させてるのでdirectionは"normal"にする
    getDirection: (direction) ->
      # directionがundefinedの時点でisReverseではない
      return defaultAnimationProperty.direction unless direction
      # default値に関わらず"normal"にする
      return "normal" if @isReverse()
      direction

    setupFreeze: () ->
      return freeze = (option) ->
        @stopAnimation @config.$el
        invoke = if callback? and option? then option.invoke else false
        invoke && callback.call @config.$el

  window.keyframeAnimation = new KeyframeAnimation()

