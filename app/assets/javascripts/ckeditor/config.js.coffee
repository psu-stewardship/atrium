CKEDITOR.editorConfig = (config) ->
  config.toolbar = [
    ['Cut','Copy','Paste','PasteText','PasteFromWord'],
    ['Bold','Italic','Underline','Strike'],
    ['Format','-','NumberedList','BulletedList','Blockquote'],
    ['Link','Unlink','Anchor','-','SelectAll','RemoveFormat'],
    ['Source','ShowBlocks','Maximize']
  ]
  true
