'use strict'

window.log = console.log.bind console
if window.location.hostname == "mybcd.mechanizm.io"
  urlApi = "http://bcd-backend.mechanizm.io"
else
  urlApi = "http://localhost:3002"
window.appConfig = { urlApi: urlApi }

Array::move = (from, to) ->
  @splice to, 0, @splice(from, 1)[0]
  @

Array::chunk = (chunkSize) ->
  r = []
  i = 0
  while i < @length
    r.push @slice(i, i + chunkSize)
    i += chunkSize
  r

Array::inGroupsOf = (groupsSize) ->
  chunkSize = Math.round(@length/groupsSize)
  @chunk(chunkSize)

$.fn.scrollTo = (target, options, callback) ->
  if typeof options is "function" and arguments.length is 2
    callback = options
    options = target
  settings = $.extend
    scrollTarget: target
    offsetTop: 50
    duration: 500
    easing: "swing"
  , options
  @each ->
    scrollPane = $(this)
    scrollTarget = (if (typeof settings.scrollTarget is "number") then settings.scrollTarget else $(settings.scrollTarget))
    scrollY = (if (typeof scrollTarget is "number") then scrollTarget else scrollTarget.offset().top + scrollPane.scrollTop() - parseInt(settings.offsetTop))
    scrollPane.animate
      scrollTop: scrollY
    , parseInt(settings.duration), settings.easing, ->
      callback.call this if typeof callback is "function"


# window.ns = (namespace) ->
#   nsparts = namespace.split(".")
#   parent = window
#   i = 0
#   while i < nsparts.length
#     partname = nsparts[i]
#     parent[partname] = {} if typeof parent[partname] is "undefined"
#     parent = parent[partname]
#     i++
#   parent

window.mutexAction = (scope, fn) ->
  ->
    semaphoreName = 'sending_xhr'
    return false if scope[semaphoreName]
    scope[semaphoreName] = true
    fn()['finally'] -> scope[semaphoreName] = false

$ ->
  # $.ui.dialog.prototype._focusTabbable = $.noop
  $.ui.dialog.prototype._focusTabbable = ->
    @uiDialog.eq(0).focus()

  $('body').append('<div class="dialog-container"/>') if $('.dialog-container').length is 0
  $('body').livequery '.dialog', (elem) ->
    $('.dialog-container').scrollTop(0)

    btn = $('<button class="close-dialog"><span class="fa fa-times"></span></button>')
    dialog = $(elem).find('.ui-dialog-content')
    dialog.append(btn)
    btn.on 'click', -> dialog.dialog 'close'


  window.fixDialog = ->
    offset = 50
    $dialog = $('.dialog')
    $window = $(window)
    if $dialog.length > 0
      wh = $window.height()
      mh = $dialog.height()
      if wh > mh + offset * 2 + 8
        $dialog.css
          top: '50%'
          transform: 'translateY(-50%)'
          margin: '0 auto'
      else
        $dialog.css
          top: 0
          transform: 'inherit'
          margin: "#{offset}px auto"
  $('body').livequery '.dialog', (elem) -> fixDialog()
  $(window).resize -> fixDialog()


$ ->
  attachFastClick = Origami.fastclick;
  attachFastClick(document.body);


(($) ->
  $.fn.visible = (options) ->
    defaults =
      partial: false
      context: window
      offset: 0
    opts = $.extend {}, defaults, options
    el = $(this)
    co = $(opts.context)

    elRect = el[0].getBoundingClientRect()
    elTop = elRect.top
    elBottom = elRect.bottom

    if opts.context is window
      coTop = 0
      coBottom = window.innerHeight
    else
      coRect = co[0].getBoundingClientRect()
      coTop = coRect.top
      coBottom = coRect.bottom

    if opts.partial
      # log "(elTop <= coBottom) and (elBottom >= coTop) ::: (#{elTop} <= #{coBottom}) and (#{elBottom} >= #{coTop})"
      (elTop <= coBottom - opts.offset) and (elBottom >= coTop + opts.offset)
    else
      # log "(elTop >= coTop) and (elBottom <= coBottom) ::: (#{elTop} >= #{coTop}) and (#{elBottom} <= #{coBottom})"
      (elTop >= coTop + opts.offset) and (elBottom <= coBottom - opts.offset)
) jQuery




angular.module 'siger.dialog', []
.provider '$dialog', ->
  defaults = @defaults =
    dialogOptions: {}
    template: 'siger.dialog'
    html: false
  _this = {}
  _this.dialogs = {}
  @$get = ($q, $templateCache, $http, $rootScope, $compile, $timeout) ->
    fetchTemplate = (template) ->
      $q.when($templateCache.get(template) or $http.get(template)).then (res) ->
        if angular.isObject(res)
          $templateCache.put template, res.data
          return res.data
        res
    (config) ->
      opts = angular.extend {}, defaults, config
      $dialog =
        options: {}
        dialogOptions: {}

      $dialog.scope = opts.scope and opts.scope.$new() or $rootScope.$new()
      $dialog.options.template = opts.template
      $dialog.options.html = opts.html
      $dialog.options.content = opts.content

      angular.forEach ['scope', 'template', 'html', 'content'], (key) -> delete opts[key]

      $dialog.dialogOptions = opts

      openFn = $dialog.dialogOptions.open
      $dialog.dialogOptions.open = (event, ui) ->
        $timeout ->
          openFn(event, ui) if openFn
          $dialog.scope.$emit '$dialog:opened', $dialog
          $dialog.open()

      closeFn = $dialog.dialogOptions.close
      $dialog.dialogOptions.close = (event, ui) ->
        $timeout ->
          closeFn(event, ui) if closeFn
          $dialog.close()

      $dialog.scope.$close = ->
        $timeout -> $dialog.ref.dialog('close')

      $dialog.id = Object.keys(_this.dialogs).length
      $dialog.$promise = fetchTemplate $dialog.options.template

      $dialog.open = ->
        $timeout ->
          $dialog.ref.dialog($dialog.dialogOptions).dialog 'open'
          $('body').addClass('dialog-open')

      $dialog.close = ->
        $timeout ->
          $dialog.ref.dialog 'close'
          $dialog.ref.dialog 'destroy'
          $dialog.scope.$destroy()
          $dialog.ref.remove()
          delete _this.dialogs[$dialog.id]
          $('body').removeClass('dialog-open') if Object.keys(_this.dialogs).length is 0

      $dialog.$promise.then (template) ->
        template = template.data if angular.isObject template
        if $dialog.options.html
          template = template.replace(/ng-bind="/ig, 'ng-bind-html="')
        if $dialog.options.content
          $dialog.scope.content = $dialog.options.content
        template = "<div>#{template.trim()}</div>"

        dialogLinker = $compile template
        $dialog.ref = $(dialogLinker($dialog.scope)).dialog($dialog.dialogOptions)

        _this.dialogs[$dialog.id] = $dialog

      $dialog
  null

.run ($templateCache, Faye) ->
  $templateCache.put 'siger.dialog', '<div ng-bind="content"></div>'
  window.fc = Faye.client
