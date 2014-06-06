package de.axelspringer.videoplayer.model.vo
{
	import de.axelspringer.videoplayer.model.vo.base.BaseVO;
	import de.axelspringer.videoplayer.model.vo.base.SkinBaseVO;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.text.StyleSheet;
	
	public class SkinVO extends BaseVO
	{
		//root objects for percentage calculation off position and size
		public static const CSS_STYLE_ROOT:String 						= "div.exozet-css";
		public static const CSS_STYLE_CONTROLBAR_ROOT:String 			= ".exozet-css.vjs-controls";
		public static const CSS_STYLE_PROGRESSBAR_ROOT:String 			= ".exozet-css.vjs-progress-control";
		
		public static const CSS_STYLE_LOADER:String 					= ".exozet-css.vjs-loader";
		public static const CSS_STYLE_BIGPLAY_BTN:String 				= ".exozet-cssspan.play";
		public static const CSS_STYLE_CONTROLBAR_DIV:String 			= ".exozet-css.vjs-controls>div";
		public static const CSS_STYLE_SEPARATOR_LEFT:String 			= ".exozet-css.vjs-controls>div.vjs-separator-left";
		public static const CSS_STYLE_SEPARATOR_RIGHT:String 			= ".exozet-css.vjs-controls>div.vjs-separator-right";
		
		public static const CSS_STYLE_PLAYPAUSE_BTN:String 				= ".exozet-css.vjs-controls>div.vjs-play-control.vjs-paused";
		public static const CSS_STYLE_PLAY_BTN_BACKGROUND:String 		= ".exozet-css.vjs-controls>div.vjs-widget-background-left";
		public static const CSS_STYLE_PLAY_BTN_BACKGROUND_LIVE:String 	= ".exozet-css.live.vjs-controls>div.vjs-widget-background-left";
		
		public static const CSS_STYLE_FULLSCREEN_BTN:String 			= ".exozet-css.vjs-controls>div.vjs-fullscreen-control";	
		public static const CSS_STYLE_HD_BTN:String 					= ".exozet-css.vjs-controls>div.vjs-hd-control";
		public static const CSS_STYLE_BILDDE_BTN:String 				= ".exozet-css.vjs-controls>div.vjs-bildde-control";
		public static const CSS_STYLE_BILDDE_BTN_TOOLTIP:String 		= ".exozet-css.video-js-box.vjs-bildde";
		public static const CSS_STYLE_SHARE_BTN:String 					= ".exozet-css.vjs-controls>div.vjs-share-control";
		public static const CSS_STYLE_SUBTITLE_BTN:String 				= ".exozet-css.vjs-controls>div.vjs-subtitle-control";

		public static const CSS_STYLE_SUBTITLE_BOX:String 				= ".exozet-css.video-js-box.vjs-subtitles";
		
		public static const CSS_STYLE_MUTE_BTN:String 					= ".exozet-css.vjs-controls>div.vjs-mute-control";
		public static const CSS_STYLE_BTN_BACKGROUND_SMALL:String 		= ".exozet-css.vjs-controls>div.vjs-widget-background-small";
		public static const CSS_STYLE_BTN_BACKGROUND_MIDDLE:String 		= ".exozet-css.vjs-controls>div.vjs-widget-background-middle";
		public static const CSS_STYLE_BTN_BACKGROUND_LARGE:String 		= ".exozet-css.vjs-controls>div.vjs-widget-background-large";
		
		public static const CSS_STYLE_TIMEDISPLAY_DYNAMIC:String 		= ".exozet-css.vjs-controls>.vjs-dynamic-time-control";
		public static const CSS_STYLE_TIMEDISPLAY_DYNAMIC_POINTER:String= ".exozet-css.vjs-controls>.vjs-dynamic-time-controldiv.vjs-time-pointer";
		
		public static const CSS_STYLE_TIMEDISPLAY:String 				= ".exozet-css.vjs-controls>div.vjs-time-control";
		public static const CSS_STYLE_TIMEDISPLAY_SEPARATOR:String 		= ".exozet-css.vjs-controls>div.vjs-time-control.vjs-time-separator";
		public static const CSS_STYLE_TIMEDISPLAY_CURRENT_TIME:String 	= ".exozet-css.vjs-controls>div.vjs-time-controldiv.vjs-current-time-display";
		public static const CSS_STYLE_TIMEDISPLAY_DURATION:String 		= ".exozet-css.vjs-controls>div.vjs-time-controldiv";
		
		public static const CSS_STYLE_VOLUMEBAR_MINUS_BTN:String 		= ".exozet-css.vjs-controls>div.vjs-volume-down";
		public static const CSS_STYLE_VOLUMEBAR_PLUS_BTN:String 		= ".exozet-css.vjs-controls>div.vjs-volume-up";
		public static const CSS_STYLE_VOLUMEBAR_HORIZONTAL:String 		= ".exozet-css.vjs-controls>div.vjs-volume-horizontal";
		public static const CSS_STYLE_VOLUMEBAR_HORIZONTAL_BAR:String 	= ".exozet-css.vjs-controls>div.vjs-volume-horizontal.ui-slider-range";
		public static const CSS_STYLE_VOLUMEBAR_VERTICAL:String 		= ".exozet-css.vjs-controls>div.vjs-volume-vertical.vertical_volume_container";
		public static const CSS_STYLE_VOLUMEBAR_VERTICAL_HIDE:String 	= ".exozet-cssdiv.vjs-volume-vertical-hide";
		public static const CSS_STYLE_VOLUMEBAR_HORIZONTAL_KNOB:String 	= ".exozet-css.horizontal_volume_containera";
		public static const CSS_STYLE_VOLUMEBAR_VERTICAL_KNOB:String 	= ".exozet-css.vertical_volume_containera";
		public static const CSS_STYLE_VOLUMEBAR_VERTICAL_HIDE_KNOB:String = ".exozet-css.vertical_hide_volume_containera";
		
		
		public static const CSS_STYLE_AD_TEXT:String 					= ".exozet-css.vjs-controls.text";
		public static const CSS_STYLE_AD_PROGRESSBAR:String 			= ".exozet-css.vjs-controls.ad-progressbar";
		public static const CSS_STYLE_PROGRESSCONTROL_LIVE:String 		= ".exozet-css.live.vjs-controls>div.vjs-progress-control";
		public static const CSS_STYLE_PROGRESSCONTROL:String 			= ".exozet-css.vjs-controls>div.vjs-progress-control";
		public static const CSS_STYLE_PROGRESSBAR:String 				= ".exozet-css.vjs-progress-control.vjs-bar-progress";
		public static const CSS_STYLE_PROGRESSBAR_KNOB:String 			= ".exozet-css.vjs-progress-control.vjs-play-progress-slider";
		public static const CSS_STYLE_PROGRESSBAR_BG:String				= ".exozet-css.vjs-progress-control.vjs-background-progress";
		public static const CSS_STYLE_PROGRESSBAR_LOAD:String			= ".exozet-css.vjs-progress-control.vjs-load-progress";
		public static const CSS_STYLE_PROGRESSBAR_PLAY:String			= ".exozet-css.vjs-progress-control.vjs-play-progress";
		
		public static const CSS_STYLE_VERTICAL_ADJUST_TOP:String 		= "top" ;
		public static const CSS_STYLE_VERTICAL_ADJUST_BOTTOM:String 	= "bottom" ;
		public static const CSS_STYLE_HORIZONTAL_ADJUST_LEFT:String 	= "left" ;
		public static const CSS_STYLE_HORIZONTAL_ADJUST_RIGHT:String	= "right" ;
		public static const CSS_STYLE_POSITION_RELATIVE:String			= "relative" ;
		public static const CSS_STYLE_POSITION_ABLOLUTE:String			= "absolute" ;
		
		
		private var _cssSprite:BitmapData;
		private var _cssStyles:StyleSheet;
		
		public var styleRoot:SkinBaseVO;
		public var styleControlsbarRoot:SkinBaseVO;
		public var styleProgressbarRoot:SkinBaseVO;
		
		public var styleLoader:SkinBaseVO;
		public var stylePlayPauseBtn:SkinBaseVO;
		public var stylePlayPauseBtnBackground:SkinBaseVO;
		public var stylePlayPauseBtnBackgroundLive:SkinBaseVO;
		public var styleSeparator1:SkinBaseVO;
		public var styleSeparator2:SkinBaseVO;
		public var styleBigPlay:SkinBaseVO;
		public var styleMuteBtn:SkinBaseVO;
		
		public var styleFullscreenBtn:SkinBaseVO;
		public var styleHDBtn:SkinBaseVO;
		public var styleSubtitleBtn:SkinBaseVO;
		public var styleBilddeBtn:SkinBaseVO;
		public var styleBilddeBtnTooltip:SkinBaseVO;
		public var styleShareBtn:SkinBaseVO;
		
		public var styleSubtitleBox:SkinBaseVO = new SkinBaseVO();
		
		public var styleAdText:SkinBaseVO = new SkinBaseVO();
		public var styleBtnBackgroundSmall:SkinBaseVO;
		public var styleBtnBackgroundMiddle:SkinBaseVO;
		public var styleBtnBackgroundLarge:SkinBaseVO;
		public var styleProgressbar:SkinBaseVO;
		public var styleProgressbarLive:SkinBaseVO;
		public var styleProgressbarKnob:SkinBaseVO;
		public var styleVolumebar:SkinBaseVO;
		public var styleVolumebarPlus:SkinBaseVO;
		public var styleVolumebarMinus:SkinBaseVO;
		public var styleVolumebarKnob:SkinBaseVO;
		public var styleTimeDisplay:SkinBaseVO;
		public var styleTimeDisplayDynamic:SkinBaseVO;
	
	//???
		public var styleJingleControl:SkinBaseVO;
		
		public function SkinVO()
		{
		}
		
		public function set cssStyles(styles:StyleSheet):void
		{
			this._cssStyles = styles;	
		}
		public function get cssStyles():StyleSheet
		{
			return this._cssStyles;
		}
		
		public function set cssSprite(sprite:BitmapData):void
		{
			this._cssSprite = sprite;	
			this.hydrate();	
		}
		public function get cssSprite():BitmapData
		{
			return this._cssSprite;
		}
			
		
		public function hydrate() :void
		{
			var styleObject:Object;
			var spritePositions:String;
			var tempstyle:SkinBaseVO;
			
			//root Objects for percentage calculation
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_ROOT ) != -1 )
			{	
				trace(this + "styleRoot detected...");
				this.styleRoot =this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_ROOT ) );
			}
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_CONTROLBAR_ROOT ) != -1 )
			{	
				trace(this + "styleControlsbarRoot detected...");
				this.styleControlsbarRoot =this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_CONTROLBAR_ROOT ) );
				//TODO check if values available for percentage calculation
				
				this.styleControlsbarRoot.displayObjectY = this.parseStyleSheet(this._cssStyles.getStyle( CSS_STYLE_CONTROLBAR_DIV )).displayObjectY;	
			}
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_PROGRESSBAR_ROOT ) != -1 )
			{	
				trace(this + "styleProgressbarRoot detected...");
				this.styleProgressbarRoot =this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_PROGRESSBAR_ROOT ) );	
			}
			
			
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_LOADER ) != -1 )
			{
				//trace(this + "Loaderstyle detected...");
				this.styleLoader = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_LOADER ) );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_BIGPLAY_BTN ) != -1 )
			{
				//trace(this + "BigPlay Button detected...");
				this.styleBigPlay = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_BIGPLAY_BTN ) );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_PLAYPAUSE_BTN ) != -1 )
			{
				//trace(this + "Playpause Button detected...");
				this.stylePlayPauseBtn = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_PLAYPAUSE_BTN ),2 );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_PLAY_BTN_BACKGROUND ) != -1 )
			{
				this.stylePlayPauseBtnBackground = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_PLAY_BTN_BACKGROUND ) );
			}
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_PLAY_BTN_BACKGROUND_LIVE ) != -1 )
			{	
				tempstyle = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_PLAY_BTN_BACKGROUND_LIVE ));
				
				this.stylePlayPauseBtnBackgroundLive = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_PLAY_BTN_BACKGROUND ));
				this.stylePlayPauseBtnBackgroundLive.buttonAdjustHorizontal = CSS_STYLE_HORIZONTAL_ADJUST_LEFT;
				this.stylePlayPauseBtnBackgroundLive.displayObjectX = tempstyle.displayObjectX;
				this.stylePlayPauseBtnBackgroundLive.skinWidth = tempstyle.skinWidth;
				this.stylePlayPauseBtnBackgroundLive.skinX = tempstyle.skinX;
				this.stylePlayPauseBtnBackgroundLive.skinY = tempstyle.skinY;	
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_SEPARATOR_LEFT ) != -1 )
			{
				//trace(this + "Playpause Button detected...");
				this.styleSeparator1 = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_SEPARATOR_LEFT ) );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_SEPARATOR_RIGHT ) != -1 )
			{
				//trace(this + "Playpause Button detected...");
				this.styleSeparator2 = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_SEPARATOR_RIGHT ) );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_FULLSCREEN_BTN ) != -1 )
			{
				//trace(this + "Fullscreen Button detected...");
				this.styleFullscreenBtn = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_FULLSCREEN_BTN ) );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_HD_BTN ) != -1 )
			{
				BildTvDefines.preHDMode = false;
				//trace(this + "HD Button detected...");
				this.styleHDBtn = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_HD_BTN ),2 );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_BILDDE_BTN ) != -1 && BildTvDefines.isEmbedPlayer )
			{
				
				BildTvDefines.preHDMode = false;
				//trace(this + "bild.de Button detected...");
				this.styleBilddeBtn = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_BILDDE_BTN ) );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_BILDDE_BTN_TOOLTIP ) != -1 && BildTvDefines.isEmbedPlayer )
			{
				//trace(this + "bild.de Button detected...");
				this.styleBilddeBtnTooltip = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_BILDDE_BTN_TOOLTIP ) );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_SUBTITLE_BTN ) != -1 )
			{
				BildTvDefines.preHDMode = false;
				//trace(this + "Subtitle Button detected...");
				this.styleSubtitleBtn = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_SUBTITLE_BTN ),2 );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_SUBTITLE_BOX ) != -1 )
			{
				//trace(this + "Subtitle Button detected...");
				this.styleSubtitleBox = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_SUBTITLE_BOX ) );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_MUTE_BTN ) != -1 )
			{
				//trace(this + "Mute Button detected...");
				this.styleMuteBtn = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_MUTE_BTN ),2 );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_VOLUMEBAR_MINUS_BTN ) != -1 )
			{
				//trace(this + "Mute Button detected...");
				this.styleVolumebarMinus = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_VOLUMEBAR_MINUS_BTN ) );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_VOLUMEBAR_PLUS_BTN ) != -1 )
			{
				//trace(this + "Mute Button detected...");
				this.styleVolumebarPlus = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_VOLUMEBAR_PLUS_BTN ) );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_SHARE_BTN ) != -1 && !BildTvDefines.isEmbedPlayer )
			{
				//trace(this + "Share Button detected...");
				this.styleShareBtn = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_SHARE_BTN ) );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_AD_TEXT ) != -1 )
			{
				//trace(this + "Share Button detected...");
				this.styleAdText = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_AD_TEXT ) );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_AD_PROGRESSBAR ) != -1 && this.styleAdText != null )
			{
				//trace(this + "Share Button detected...");
				this.styleAdText.display = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_AD_PROGRESSBAR )).display;
			}
						
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_VOLUMEBAR_HORIZONTAL_KNOB ) != -1 )
			{
				//trace(this + "Volume Knob detected...");
				this.styleVolumebarKnob = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_VOLUMEBAR_HORIZONTAL_KNOB ) );
			}
			else if( this._cssStyles.styleNames.indexOf( CSS_STYLE_VOLUMEBAR_VERTICAL_KNOB ) != -1 )
			{
				//trace(this + "Volume Knob detected...");
				this.styleVolumebarKnob = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_VOLUMEBAR_VERTICAL_KNOB ) );
			}
			else if( this._cssStyles.styleNames.indexOf( CSS_STYLE_VOLUMEBAR_VERTICAL_HIDE_KNOB ) != -1 )
			{
				//trace(this + "Volume Knob detected...");
				this.styleVolumebarKnob = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_VOLUMEBAR_VERTICAL_HIDE_KNOB ) );
			}
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_PROGRESSBAR_KNOB ) != -1 )
			{
				//trace(this + "Progress Knob detected...");
				this.styleProgressbarKnob = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_PROGRESSBAR_KNOB ) );
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_TIMEDISPLAY ) != -1 ||
				this._cssStyles.styleNames.indexOf( CSS_STYLE_TIMEDISPLAY_CURRENT_TIME ) != -1 ||
				this._cssStyles.styleNames.indexOf( CSS_STYLE_TIMEDISPLAY_SEPARATOR ) != -1 ||
				this._cssStyles.styleNames.indexOf( CSS_STYLE_TIMEDISPLAY_DURATION ) != -1 )
			{
				//trace(this + "Timedisplay detected...");
				this.styleTimeDisplay = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_TIMEDISPLAY ) );
				
				
				if( this._cssStyles.getStyle( CSS_STYLE_TIMEDISPLAY_CURRENT_TIME ) )
				{
					this.styleTimeDisplay.loadColor = this.parseStyleSheet(this._cssStyles.getStyle( CSS_STYLE_TIMEDISPLAY_CURRENT_TIME )).color ;	
				}
				if( this._cssStyles.getStyle( CSS_STYLE_TIMEDISPLAY_DURATION ) )
				{
					this.styleTimeDisplay.color = this.parseStyleSheet(this._cssStyles.getStyle( CSS_STYLE_TIMEDISPLAY_DURATION )).color ;	
				}
				if( this._cssStyles.getStyle( CSS_STYLE_TIMEDISPLAY_SEPARATOR ) )
				{
					this.styleTimeDisplay.rotation = ( this._cssStyles.getStyle( CSS_STYLE_TIMEDISPLAY_SEPARATOR ).MozTransform != undefined) ? true : false;	
				}
			}
			else if(this._cssStyles.styleNames.indexOf( CSS_STYLE_TIMEDISPLAY_DYNAMIC ) != -1 )	
			{
				this.styleTimeDisplayDynamic = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_TIMEDISPLAY_DYNAMIC ) );
			}	
		
			if( 
				this._cssStyles.styleNames.indexOf( CSS_STYLE_PROGRESSBAR_LOAD ) != -1 	||
				this._cssStyles.styleNames.indexOf( CSS_STYLE_PROGRESSBAR_PLAY ) != -1 	||
				this._cssStyles.styleNames.indexOf( CSS_STYLE_PROGRESSCONTROL ) != -1 
			  )
			{
				//trace(this + "Progressbar detected...");
				this.styleProgressbar = new SkinBaseVO();
			
				if( this._cssStyles.getStyle( CSS_STYLE_PROGRESSCONTROL ) )
				{
					this.styleProgressbar = this.parseStyleSheet(this._cssStyles.getStyle( CSS_STYLE_PROGRESSCONTROL )) ;	
				}
				if( this._cssStyles.getStyle( CSS_STYLE_PROGRESSBAR_LOAD ) )
				{
					this.styleProgressbar.loadColor = this.parseStyleSheet(this._cssStyles.getStyle( CSS_STYLE_PROGRESSBAR_LOAD )).backgroundColor ;	
				}
				if( this._cssStyles.getStyle( CSS_STYLE_PROGRESSBAR_BG ) )
				{
					this.styleProgressbar.backgroundColor = this.parseStyleSheet(this._cssStyles.getStyle( CSS_STYLE_PROGRESSBAR_BG )).backgroundColor ;	
				}
				if( this._cssStyles.getStyle( CSS_STYLE_PROGRESSCONTROL ) )
				{
					var widthInPercent:String = this._cssStyles.getStyle( CSS_STYLE_PROGRESSCONTROL ).width;
					
					if( widthInPercent == "100%" )
					{
						this.styleProgressbar.position = CSS_STYLE_POSITION_ABLOLUTE;
					}
					else
					{
						this.styleProgressbar.position = CSS_STYLE_POSITION_RELATIVE;
					}					
				}
				if( this._cssStyles.getStyle( CSS_STYLE_PROGRESSBAR_PLAY ) )
				{
					//this.styleProgressbar.displayObjectY = this.parseStyleSheet(this._cssStyles.getStyle( CSS_STYLE_PROGRESSBAR_PLAY )).displayObjectY ;	
					this.styleProgressbar.color = this.parseStyleSheet(this._cssStyles.getStyle( CSS_STYLE_PROGRESSBAR_PLAY )).backgroundColor ;	
					this.styleProgressbar.skinHeight = this.parseStyleSheet(this._cssStyles.getStyle( CSS_STYLE_PROGRESSBAR_PLAY )).skinHeight ;	
					this.styleProgressbar.displayObjectY = this.parseStyleSheet(this._cssStyles.getStyle( CSS_STYLE_PROGRESSBAR_PLAY )).displayObjectY ;	
				}
				if( this._cssStyles.getStyle( CSS_STYLE_PROGRESSBAR_PLAY ) )
				{
					this.styleProgressbar.alpha = this.parseStyleSheet(this._cssStyles.getStyle( CSS_STYLE_PROGRESSBAR_PLAY )).alpha;
					this.styleProgressbar.alpha2 = this.parseStyleSheet(this._cssStyles.getStyle( CSS_STYLE_PROGRESSBAR_LOAD )).alpha;
					this.styleProgressbar.alpha3 = this.parseStyleSheet(this._cssStyles.getStyle( CSS_STYLE_PROGRESSBAR_BG )).alpha;
				}
				
				if( this._cssStyles.styleNames.indexOf( CSS_STYLE_PROGRESSCONTROL_LIVE ) != -1 )
				{	
					tempstyle = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_PROGRESSCONTROL_LIVE ));
						
					this.styleProgressbarLive = this.styleProgressbar;
					this.styleProgressbarLive.buttonAdjustHorizontal = CSS_STYLE_HORIZONTAL_ADJUST_LEFT;
					this.styleProgressbarLive.displayObjectX = tempstyle.displayObjectX;
				}		
			}			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_VOLUMEBAR_HORIZONTAL ) != -1 )
			{
				//trace(this + "Volume Horizontal detected...");
				this.styleVolumebar = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_VOLUMEBAR_HORIZONTAL ));
				this.styleVolumebar.rotation = false;	
				this.styleVolumebar.hideable = false;	
				
				if( this._cssStyles.styleNames.indexOf( CSS_STYLE_VOLUMEBAR_HORIZONTAL_BAR ) != -1 )
				{
					//trace(this + "Volume Horizontal detected...");
					this.styleVolumebar.color = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_VOLUMEBAR_HORIZONTAL_BAR )).backgroundColor;
				}
				
				
			}
			else if( this._cssStyles.styleNames.indexOf( CSS_STYLE_VOLUMEBAR_VERTICAL ) != -1 )
			{
				//trace(this + "Volume Vertical detected...");
				this.styleVolumebar = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_VOLUMEBAR_VERTICAL ));
				this.styleVolumebar.rotation = true;	
				this.styleVolumebar.hideable = false;	
			}
			else if( this._cssStyles.styleNames.indexOf( CSS_STYLE_VOLUMEBAR_VERTICAL_HIDE ) != -1 )
			{
				//trace(this + "Volume Vertical detected...");
				this.styleVolumebar = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_VOLUMEBAR_VERTICAL_HIDE ));
				this.styleVolumebar.rotation = true;	
				this.styleVolumebar.hideable = true;	
			}
			
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_BTN_BACKGROUND_SMALL ) != -1 )
			{
				this.styleBtnBackgroundSmall = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_BTN_BACKGROUND_SMALL ) );
			}
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_BTN_BACKGROUND_MIDDLE ) != -1 )
			{
				this.styleBtnBackgroundMiddle = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_BTN_BACKGROUND_MIDDLE ) );
			}
			if( this._cssStyles.styleNames.indexOf( CSS_STYLE_BTN_BACKGROUND_LARGE ) != -1 )
			{
				this.styleBtnBackgroundLarge = this.parseStyleSheet( this._cssStyles.getStyle( CSS_STYLE_BTN_BACKGROUND_LARGE ) );
			}
		}	
				
		protected function parseStyleSheet( stylesheet:Object, phases:Number = 1 ) :SkinBaseVO
		{
			var skin:SkinBaseVO = new SkinBaseVO();
			var settedParameter:Number = 0;
			
			if( stylesheet.display )
			{
				skin.display = stylesheet.display;
				settedParameter++;	
			}
			if( stylesheet.backgroundColor )
			{
				var bcObj:Object = this.parseColor( stylesheet.backgroundColor );
				skin.backgroundColor = bcObj.color;
				if( bcObj.alpha != 0 ) skin.alpha = bcObj.alpha;
				settedParameter++;	
			}
			
			if( stylesheet.color )
			{
				var cObj:Object = this.parseColor( stylesheet.color );
				skin.color = cObj.color;
				settedParameter++;	
			}
			
			if( stylesheet.fontSize )
			{
				skin.fontsize = this.parseNumbers( stylesheet.fontSize );
				settedParameter++;	
			}
			
			if( stylesheet.lineHeight )
			{
				skin.fontHeight = this.parseNumbers( stylesheet.lineHeight );
				settedParameter++;	
			}
			
			if( stylesheet.textAlign )
			{
				skin.fontAlign = stylesheet.textAlign;
				settedParameter++;	
			}
			
			if( stylesheet.height )
			{	
				skin.skinHeight = this.parseNumbers( stylesheet.height);
				settedParameter++;	
			}
			
			if( stylesheet.width )
			{
				skin.skinWidth = this.parseNumbers( stylesheet.width );
				settedParameter++;	
			}
			
			if( stylesheet.right )
			{
				skin.buttonAdjustHorizontal = CSS_STYLE_HORIZONTAL_ADJUST_RIGHT;
				skin.displayObjectX = this.parseNumbers( stylesheet.right );
				settedParameter++;	
			}
			else if( stylesheet.left )
			{
				skin.buttonAdjustHorizontal = CSS_STYLE_HORIZONTAL_ADJUST_LEFT;
				skin.displayObjectX = this.parseNumbers( stylesheet.left );
				settedParameter++;	
			}
			
			if( stylesheet.top )
			{
				skin.buttonAdjustVertical = CSS_STYLE_VERTICAL_ADJUST_TOP;
				skin.displayObjectY = this.parseNumbers( stylesheet.top );
				settedParameter++;	
			}
			if( stylesheet.bottom && skin.displayObjectY == 0 )
			{
				skin.buttonAdjustVertical = CSS_STYLE_VERTICAL_ADJUST_BOTTOM;
				skin.displayObjectY = this.parseNumbers( stylesheet.bottom );
				settedParameter++;	
			}
				
			if( stylesheet.backgroundPosition )
			{	
				var pos:Point = this.parsePosition( stylesheet.backgroundPosition );
				skin.skinX = pos.x;
				skin.skinY = pos.y;
				settedParameter++;	
			}
			
			if( stylesheet.position )
			{	
				skin.position = stylesheet.position;
				settedParameter++;	
			}
			
			if( stylesheet.MozTransform )
			{	
				skin.rotation = true;
				settedParameter++;	
			}
			
			if( stylesheet.borderRadius )
			{	
				skin.borderRadius = this.parseNumbers( stylesheet.borderRadius );
				settedParameter++;	
			}
			else if(stylesheet.borderTopLeftRadius )
			{
				skin.borderRadiusTop = this.parseNumbers( stylesheet.borderTopLeftRadius );
				settedParameter++;	
			}
			else if(stylesheet.borderTopRightRadius )
			{
				skin.borderRadiusTop = this.parseNumbers( stylesheet.borderTopLeftRadius );
				settedParameter++;	
			}
			
			if( stylesheet.opacity && skin.alpha == 1 )
			{	
				skin.alpha = this.parseNumbers( stylesheet.opacity );
				settedParameter++;	
			}
			
			skin.skinPhases = phases;
			
			if( settedParameter > 0 )
			{
				skin.skinReady = true;
			}
			return skin;
		}
		
		protected function parseNumbers( numberString:String, rootString:String = "" ) :Number
		{
			var numString:String = this.cleanNumberString( numberString );
			var num:Number = 0;
			
			if( !isNaN(  Number( numString ) ) )
			{
				num = Number( numString );
			}
			else if( numberString.indexOf("%") != -1)
			{
				numberString = numString.split("%").join("");
				var rootValue:String = this.cleanNumberString( rootString );
				//TODO get value for the percentage calculation
				
				num = Number(numberString)/100;// /rootValue
			}
			
			return num;
		}
		
		protected function cleanNumberString( oldNumString:String ) :String
		{
			var numString:String = oldNumString;
			
			numString = numString.split("px").join("");
			numString = numString.split("-").join("");
			numString = numString.split(" ").join("");
			
			return numString;
		}
		
		protected function parsePosition( positionString:String ) :Point
		{
			positionString = positionString.split("-").join(" "); 
			positionString = positionString.slice(1);
			
			var positionArray:Array = positionString.split(" ");
			var positionPoint:Point;
			
			positionPoint = new Point(this.parseNumbers( positionArray[0] ) , this.parseNumbers( positionArray[1] ) );
				
			return positionPoint;
		}	
		
		protected function parseColor( s:String ) :Object
		{
			var color:Number = 0;
			var alpha:Number = 0;
			
			if( s!= null )
			{
				if( s.charAt( 0 ) == "#" )
				{
					s = s.substr( 1 );	
					
					if( s.length == 3 )
					{	
						var longValue:String = "";
						longValue = s.charAt(0) + s.charAt(0);
						longValue += s.charAt(1) + s.charAt(1);
						longValue += s.charAt(2) + s.charAt(2);
						s = longValue;
					}
					
				}
				else if(s == "black")
				{
					s = "000000";
				}
				else if(s == "white")
				{
					s = "ffffff";
				}
				else if(s.indexOf("rgb") != -1)
				{
					var rgbElements:String;
					rgbElements = s.substring(s.indexOf("(") + 1,s.indexOf(")"));
					var rgbValues:Array = new Array();
					rgbValues = rgbElements.split(",");
					color = this.parseRGBColor(rgbValues[0],rgbValues[1],rgbValues[2]);
					alpha = rgbValues[3];
				}
				if(color == 0 && s.indexOf("rgb") == -1) color = parseInt( s, 16 );
			}
			
			return {color:color,alpha:alpha};
		}
		
		protected function parseRGBColor(r:uint = 0, g:uint = 0, b:uint = 0):uint
        {
           // trace('> convert RGBA into HEX');
            
            var arrCol:Array = [b, g, r];
            var color:uint = 0;
            for (var i:uint = 0; i < arrCol.length; i++)
            {
                color |= (0xFF & (arrCol[i] as uint)) << (i * 8);
            }
            
            return color;
        }
	}
}