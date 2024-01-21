

function DrawLocation( userid )

    _GModText_Start( "CloseCaption_Bold" );
    _GModText_SetColor( 255, 255, 255, 255 );
    _GModText_SetPos( 0.02, 0.02 );
    _GModText_SetTime( 9999, 0, 0 );
    _GModText_SetText("You are currently in");
    _GModText_AllowOffscreen(false);
   _GModText_Send( userid, 99 );	

end


function LocationInserter( Activator, Caller, Location )
    _GModText_Start( "TargetID" );
			 _GModText_SetColor( 255, 255, 255, 255 );
			 _GModText_SetPos( 0.04, 0.05 );
             _GModText_SetTime( 9999, 0, 0 );
			 _GModText_SetText( Location );
			_GModText_Send( Activator, 100 );	
end