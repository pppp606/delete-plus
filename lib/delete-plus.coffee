{CompositeDisposable} = require 'atom'

module.exports = DeletePlus =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'delete-plus:delete': => @delete()

  delete: ->
    editor = atom.workspace.getActiveTextEditor()
    for cursorPos in editor.getCursorBufferPositions()
      buffer = editor.getTextInBufferRange([[cursorPos.row,cursorPos.column-1], cursorPos])
      if buffer == "(" || buffer == "{" || buffer == ">" || buffer == "<" || buffer == "[" || buffer == "'" || buffer == '"'
        startpoint = 0
        switch buffer
          when "("
            endtype = "\\)"
          when "{"
            endtype = "\\}"
          when "<"
            endtype = ">"
          when ">"
            endtype = "<"
            startpoint = 1
          when "["
            endtype = "]"
          else
            endtype = buffer

        strPos = [cursorPos.row,cursorPos.column+startpoint]
        endPos = [cursorPos.row,cursorPos.column+9999]

        editor.scanInBufferRange(///.*?#{endtype}///,[strPos,endPos], ((returnObj) ->
          strRan = [returnObj.range.start.row,returnObj.range.start.column-startpoint]
          endRan = [returnObj.range.end.row,returnObj.range.end.column-1]
          editor.setTextInBufferRange([strRan,endRan],"")
        ))

      else
        editor.deleteToEndOfWord()
