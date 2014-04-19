do (window) ->
  'use strict'

  # CSSのプロパティをいい感じに扱う
  window.CSSProperty =
    animationEnd: "webkitAnimationEnd animationEnd animationend"

    # VendorPrefixが必要なプロパティを探して付ける(今はWebkitだけ…)
    # e.g. transform         -> WebkitTransform
    #      animationFillMode -> WebkitAnimationFillMode
    #      opacity           -> opacity
    # option.dasherize == trueならdasherizeする
    addVendorPrefix: (rules, option) ->
      # vendor prefixが必要なプロパティ
      # めんどくさいからアニメーションで使いそうなやつだけ
      # via. http://peter.sh/experiments/vendor-prefixed-css-property-overview/
      needPrefix = [
        /^transform/
        /^transition/
        /^animation/
        /^border.*Radius$/
      ]
      isNeed = (prop) -> _.some needPrefix, (exp) -> exp.test prop

      prefixed = _.clone rules
      _.each rules, (value, key) ->
        prefixed["Webkit#{_.string.capitalize(key)}"] = value if isNeed(key)

      return CSSProperty.toDasherizeKey(prefixed) if option?.dasherize
      prefixed

    # アニメーションのプロパティをショートカットで指定したい
    # VendorPrefixも勝手につけて欲しい
    # e.g. name: "hoge"    -> animationName: "hoge", WebkitAnimationName: "hoge"
    # option.dasherize == trueならdasherizeする
    toAnimationProperty: (rules, option) ->
      # まずはフルネーム化
      fullName = _.map _.keys(rules), (key) -> "animation#{_.string.capitalize key}"
      prefixed = _.object fullName, _.values rules

      # VendorPrefixつける
      # optionで指定されてたらdasherizeもする
      CSSProperty.addVendorPrefix prefixed, option

    # transform-functionをキーにして指定したい
    # e.g. {translateX: "100px", rotate: (10deg)} -> transform: "translateX(100px) rotate(10deg)"
    toTransformFunction: (rules) ->
      functionList = [
        /^matrix/
        /^translate/
        /^scale/
        /^rotate/
        /^skew/
        /perspective/
      ]
      isTransform = (name) -> _.some functionList, (exp) -> exp.test name
      transforms = rules.transform?.split(" ") || []

      _rules = _.clone rules
      _.each _rules, (val, key, rules) ->
        unless isTransform key
          return

        transforms.push "#{key}(#{val})"
        delete rules[key]

      _rules.transform = transforms.join " "
      _rules

    # オブジェクトのkeyをcamelcaseからdasherizeに変換する
    # e.g. WebkitTransform: "scale(1)"         -> -webkit-transform: "scale(1)"
    #      WebkitAnimationFillMode: "forwards" -> -webkit-animation-fill-mode: "forwards"
    toDasherizeKey: (obj) ->
      dasherizeKeys = _.map _.keys(obj), (val) -> _.string.dasherize val
      _.object dasherizeKeys, _.values obj


