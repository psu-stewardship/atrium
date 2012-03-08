CKEDITOR.plugins.add('linkItem',
{
    init: function(editor)
    {
        var pluginName = 'linkItem';
        CKEDITOR.dialog.add(pluginName, this.path + 'dialogs/linkItem.js');
        // Register the command used to open the dialog.
		editor.addCommand( pluginName, new CKEDITOR.dialogCommand(pluginName));
        editor.ui.addButton( 'linkItem',
						{
							label : 'Link Item',
							command : pluginName ,
                            icon: CKEDITOR.plugins.getPath('linkItem') + 'application_link.png'
						} );
    }
});