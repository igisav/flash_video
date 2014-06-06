package de.axelspringer.videoplayer.ui
{
	import de.axelspringer.videoplayer.event.ControlEvent;
	import de.axelspringer.videoplayer.model.vo.AdTimerTextVO;
	import de.axelspringer.videoplayer.model.vo.BildTvDefines;
	import de.axelspringer.videoplayer.model.vo.SkinVO;
	import de.axelspringer.videoplayer.ui.controls.AdControls;
	import de.axelspringer.videoplayer.ui.controls.ControlButton;
	import de.axelspringer.videoplayer.ui.controls.ProgressBar;
	import de.axelspringer.videoplayer.ui.controls.VolumeControlHorizontal;
	import de.axelspringer.videoplayer.ui.controls.VolumeControlVertical;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import nhe.ui.IconButton;
	import nhe.ui.MultiIconButton;
	
	import tv.tvnext.stdlib.utils.StringUtils;
	
	public class ControlsPanel extends Sprite
	{
		public var separator_1:IconButton;
		public var separator_2:IconButton;
		
		//flexible buttons
		public var bilddeBtn:IconButton;//nur bei embed
		public var bilddeBtnTooltip:IconButton;
		public var shareBtn:IconButton; //nicht bei embed
		public var subtitleBtn:MultiIconButton;
		public var hdBtn:MultiIconButton;
		public var muteBtn:MultiIconButton;
		
		public var volumeMinusBtn:IconButton;
		public var volumePlusBtn:IconButton;
		
		public var fullscreenBtn:IconButton;
		public var playPauseBtn:MultiIconButton;
		public var playPauseBtnBackground:IconButton;
		public var playPauseBtnBackgroundLive:IconButton;
		
		// logic
		public var progressBar:ProgressBar;
		public var progressbarMaskSprite:Sprite;
		public var volumeControl:*;
		public var volumeControlMode:String;
		
		public var timeDisplay:TimeDisplay;
		public var timeDisplayDynamic:TimeDisplayDynamic;
		public var background:Sprite = new Sprite;
		public var btnBackgroundSmall:IconButton;
		public var btnBackgroundMiddle:IconButton;
		public var btnBackgroundLarge:IconButton;
		public var jingleControls:Sprite = new Sprite;
		
		public var adControls:AdControls;
		
		public var skin:SkinVO;
		
		public var visibleButtons:Number = 0;
		
		private var initialized:Boolean = false;
	
		public function ControlsPanel()
		{
			super();
			
			this.adControls = new AdControls();
						
			this.adControls.visible = false;
			this.adControls.visibility = false;
			this.jingleControls.visible = false; 
		}
				
		public function setSkin( skin:SkinVO, adText:AdTimerTextVO ) :void
		{
			this.skin = skin;
			if( skin.styleAdText ) this.adControls.setSkin(skin.styleAdText);
			this.adControls.setAdTimerText( adText );
				
			this.initElements();
		}
		
		/* 
		if the button is styled in the css file, then the button will be placed on the screen
		 */
		public function initElements():void 
		{		
			var ct:ColorTransform = new ColorTransform();
			this.y = 0;
									
			if( this.skin.styleControlsbarRoot != null )
			{
				if( this.skin.styleControlsbarRoot.position == SkinVO.CSS_STYLE_POSITION_RELATIVE )
				{
					this.background.graphics.beginFill( this.skin.styleControlsbarRoot.backgroundColor );
					this.background.graphics.drawRect( this.skin.styleControlsbarRoot.displayObjectX, this.skin.styleControlsbarRoot.displayObjectY, BildTvDefines.width, this.skin.styleControlsbarRoot.skinHeight);
					this.background.graphics.endFill();
				}
				if(this.skin.styleControlsbarRoot.position == SkinVO.CSS_STYLE_POSITION_ABLOLUTE)
				{
					BildTvDefines.isWidgetPlayer = true;
					if( this.skin.styleProgressbar != null )
					{
						this.background.graphics.beginFill(this.skin.styleControlsbarRoot.color);
		         		this.background.graphics.drawRoundRect(this.skin.styleControlsbarRoot.displayObjectX, 0,300,this.skin.styleControlsbarRoot.skinHeight, this.skin.styleProgressbar.borderRadius);
		         		this.background.graphics.endFill(); 
		         		this.background.alpha = this.skin.styleProgressbar.alpha;	
					}
					
				}
         		
				this.addChild(this.background);
				this.background.y = -this.skin.styleControlsbarRoot.displayObjectY;
			}
			if( this.skin.stylePlayPauseBtnBackground != null )
			{	
				this.playPauseBtnBackground = new IconButton(this.skin.cssSprite, this.skin.stylePlayPauseBtnBackground.skinWidth, this.skin.stylePlayPauseBtnBackground.skinHeight, this.skin.stylePlayPauseBtnBackground.skinX, this.skin.stylePlayPauseBtnBackground.skinY ); 		
				this.addChild(this.playPauseBtnBackground);				
				this.playPauseBtnBackground.y = (this.skin.stylePlayPauseBtnBackground.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.playPauseBtnBackground.height - this.skin.stylePlayPauseBtnBackground.displayObjectY ) : this.skin.stylePlayPauseBtnBackground.displayObjectY;			
				this.playPauseBtnBackground.enabled = false;				
			}
			if( this.skin.stylePlayPauseBtnBackgroundLive != null )
			{
				this.playPauseBtnBackgroundLive = new IconButton(this.skin.cssSprite, this.skin.stylePlayPauseBtnBackgroundLive.skinWidth, this.skin.styleBtnBackgroundLarge.skinHeight, this.skin.stylePlayPauseBtnBackgroundLive.skinX, this.skin.stylePlayPauseBtnBackgroundLive.skinY ); 
				this.addChild(this.playPauseBtnBackgroundLive);
				this.playPauseBtnBackgroundLive.y = (this.skin.stylePlayPauseBtnBackgroundLive.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.playPauseBtnBackgroundLive.height - this.skin.stylePlayPauseBtnBackgroundLive.displayObjectY ) : this.skin.stylePlayPauseBtnBackgroundLive.displayObjectY;	
				this.playPauseBtnBackgroundLive.enabled = false;
			}
			if( this.skin.stylePlayPauseBtn != null )
			{
				this.playPauseBtn = new MultiIconButton(this.skin.cssSprite, this.skin.stylePlayPauseBtn.skinWidth, this.skin.stylePlayPauseBtn.skinHeight, this.skin.stylePlayPauseBtn.skinX, this.skin.stylePlayPauseBtn.skinY, this.skin.stylePlayPauseBtn.skinPhases ); 
				this.addChild(this.playPauseBtn);
				this.playPauseBtn.y = (this.skin.stylePlayPauseBtn.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.playPauseBtn.height - this.skin.stylePlayPauseBtn.displayObjectY ) : this.skin.stylePlayPauseBtn.displayObjectY;	
				this.playPauseBtn.addEventListener(MouseEvent.CLICK, onMultiIconBtnClick );
				this.playPauseBtn.addEventListener(MouseEvent.CLICK, onBtnClick );
			}
			if( this.skin.styleSeparator1 != null )
			{
				this.separator_1 = new IconButton(this.skin.cssSprite, this.skin.styleSeparator1.skinWidth, this.skin.styleSeparator1.skinHeight, this.skin.styleSeparator1.skinX, this.skin.styleSeparator1.skinY ); 
				this.addChild(this.separator_1);
				this.separator_1.enabled = false;
				this.separator_1.y = (this.skin.styleSeparator1.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.separator_1.height - this.skin.styleSeparator1.displayObjectY ) : this.skin.styleSeparator1.displayObjectY;	
			}
			if( this.skin.styleSeparator2 != null )
			{
				this.separator_2 = new IconButton(this.skin.cssSprite, this.skin.styleSeparator2.skinWidth, this.skin.styleSeparator2.skinHeight, this.skin.styleSeparator2.skinX, this.skin.styleSeparator2.skinY ); 
				this.addChild(this.separator_2);
				this.separator_2.enabled = false;
				this.separator_2.y = (this.skin.styleSeparator2.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.separator_2.height - this.skin.styleSeparator2.displayObjectY ) : this.skin.styleSeparator2.displayObjectY;	
			}
			if( this.skin.styleVolumebar != null )
			{
				if( this.skin.styleVolumebar.rotation == true )
				{
					this.volumeControl = new VolumeControlVertical(); 
					this.volumeControlMode = VolumeControlVertical.NAME;
					
					this.addChild(this.volumeControl);
					 
					var background:Sprite = new Sprite();
					background.graphics.beginFill( this.skin.styleVolumebar.backgroundColor );
					
					if( true == BildTvDefines.isWidgetPlayer )
					{
						this.volumeControl.y = -110;//(this.skin.styleVolumebar.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.volumeControl.height/4 - this.skin.styleVolumebar.displayObjectY ) : this.skin.styleVolumebar.displayObjectY - this.volumeControl.height/4;	
						background.graphics.drawRect( this.skin.styleVolumebar.displayObjectX, this.skin.styleVolumebar.displayObjectY- 10, this.skin.styleVolumebar.skinWidth * 3, this.skin.styleVolumebar.skinHeight + 20);		
					} else 
					{
						this.volumeControl.y = -60;
						background.y = -10;
						background.graphics.drawRect( this.skin.styleVolumebar.displayObjectX, this.skin.styleVolumebar.displayObjectY, this.skin.styleVolumebar.skinWidth * 3, this.skin.styleVolumebar.skinHeight *2);
					}
					background.graphics.endFill();
					
					this.volumeControl.alpha = this.background.alpha;
					this.volumeControl.background.addChild(background);	
					this.volumeControl.background.x = -this.volumeControl.background.width / 3;
					
					var volumeBar:IconButton = new IconButton(this.skin.cssSprite, this.skin.styleVolumebar.skinWidth, this.skin.styleVolumebar.skinHeight, this.skin.styleVolumebar.skinX + this.skin.styleVolumebar.skinWidth, this.skin.styleVolumebar.skinY ); 
					var volumeBg:IconButton = new IconButton(this.skin.cssSprite, this.skin.styleVolumebar.skinWidth, this.skin.styleVolumebar.skinHeight, this.skin.styleVolumebar.skinX, this.skin.styleVolumebar.skinY ); 
				
					
					volumeBar.enabled = false;
					volumeBg.enabled = false;
					
					if( true == BildTvDefines.isWidgetPlayer )
					{
						volumeBar.x = ( background.width - volumeBar.width )/2 -1;	
						volumeBg.x = ( background.width - volumeBg.width )/2;	
						this.volumeControl.btn.x = ( background.width - this.skin.styleVolumebar.skinWidth )/2;		
					}
					
					this.volumeControl.btn.height = this.skin.styleVolumebar.skinHeight; 
					this.volumeControl.btn.width = this.skin.styleVolumebar.skinWidth; 
					this.volumeControl.paneMask.y = volumeBar.height;
					this.volumeControl.paneMask.height = this.skin.styleVolumebar.skinHeight;
					this.volumeControl.paneMask.width = this.skin.styleVolumebar.skinWidth;
					this.volumeControl.paneMask.scaleY = -3.5;
					this.volumeControl.paneMask.x = this.volumeControl.btn.x;	
					
					this.volumeControl.volumePane.addChild(volumeBar);
					this.volumeControl.volumePaneBg.addChild(volumeBg);
					
					if( this.skin.styleVolumebarKnob != null && this.skin.styleVolumebarKnob.skinReady == true && this.skin.styleVolumebarKnob.display != "none")
					{
						var volumeKnob:IconButton = new IconButton(this.skin.cssSprite, this.skin.styleVolumebarKnob.skinWidth, this.skin.styleVolumebarKnob.skinHeight, this.skin.styleVolumebarKnob.skinX, this.skin.styleVolumebarKnob.skinY ); 
						this.volumeControl.dragger.addChild(volumeKnob);
						volumeKnob.y = -5;	
						volumeKnob.x = -2;	
						volumeKnob.enabled = false;
						this.volumeControl.dragger.y = volumeBar.height/2;//-this.volumeControl.volumePane.height / 2;
					}
					
					if( this.skin.styleVolumebar.hideable == true )
					{
						this.volumeControl.addEventListener(MouseEvent.MOUSE_OVER, onShowVolumebar );
						this.volumeControl.addEventListener(MouseEvent.MOUSE_OUT, onHideVolumebar );
						this.volumeControl.visible = false;  		
					}
				}
				else
				{
					//volumebar horizontal und nicht rotiert
					this.volumeControl = new VolumeControlHorizontal(); 
					this.volumeControlMode = VolumeControlHorizontal.NAME;
					this.volumeControl.y = (this.skin.styleVolumebar.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.volumeControl.height/4 - this.skin.styleVolumebar.displayObjectY ) : this.skin.styleVolumebar.displayObjectY - this.volumeControl.height/4;	
					this.addChild(this.volumeControl);
					this.volumeControl.volume= 0.5;
					this.volumeControl.setSkin(skin.styleVolumebar);
				}	
			}
			if( this.skin.styleTimeDisplay != null )
			{
				this.timeDisplay = new TimeDisplay();
				
				this.timeDisplay.txtTimeTotal.text = "00:00";
				this.timeDisplay.txtTimeVideo.text = "00:00";
			
				this.addChild(this.timeDisplay);
				
				this.timeDisplay.y = (this.skin.styleTimeDisplay.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.timeDisplay.height - this.skin.styleTimeDisplay.displayObjectY ) : this.skin.styleTimeDisplay.displayObjectY *2;	
				
				ct.color = this.skin.styleTimeDisplay.color;		
				this.timeDisplay.txtTimeTotal.transform.colorTransform = ct; 
				this.timeDisplay.separatorMc.transform.colorTransform = ct; 
				this.timeDisplay.slashMc.transform.colorTransform = ct; 
				
				if( true == this.skin.styleTimeDisplay.rotation )
				{
					this.timeDisplay.separatorMc.visible = false;
					this.timeDisplay.slashMc.visible = true;
				}
				else
				{
					this.timeDisplay.separatorMc.visible = true;
					this.timeDisplay.slashMc.visible = false;
				}
						
				ct.color = this.skin.styleTimeDisplay.loadColor;
				this.timeDisplay.txtTimeVideo.transform.colorTransform = ct; 
			}
			else if( this.skin.styleTimeDisplayDynamic )
			{
				this.timeDisplayDynamic = new TimeDisplayDynamic();
				
				this.timeDisplayDynamic.txtTimeVideo.autoSize = TextFieldAutoSize.RIGHT;
				this.timeDisplayDynamic.text = "00:00";
				this.timeDisplayDynamic.y = - this.skin.styleTimeDisplayDynamic.displayObjectY;	
				this.timeDisplayDynamic.visible = false;
			
				this.addChild(this.timeDisplayDynamic);
				
			
			}
			if( ( 	this.skin.styleBtnBackgroundSmall != null &&
			 		this.skin.styleBtnBackgroundMiddle != null &&
			 		this.skin.styleBtnBackgroundLarge != null ) &&
					(this.skin.styleHDBtn != null ||
					this.skin.styleShareBtn!= null ||
					this.skin.styleBilddeBtn!= null ||
					this.skin.styleSubtitleBtn!= null ||
					this.skin.styleFullscreenBtn != null ||
					this.skin.styleMuteBtn != null) )
			{
				
				this.btnBackgroundSmall = new IconButton(this.skin.cssSprite, this.skin.styleBtnBackgroundSmall.skinWidth, this.skin.styleBtnBackgroundSmall.skinHeight, this.skin.styleBtnBackgroundSmall.skinX, this.skin.styleBtnBackgroundSmall.skinY ); 
				this.btnBackgroundMiddle = new IconButton(this.skin.cssSprite, this.skin.styleBtnBackgroundMiddle.skinWidth, this.skin.styleBtnBackgroundMiddle.skinHeight, this.skin.styleBtnBackgroundMiddle.skinX, this.skin.styleBtnBackgroundMiddle.skinY ); 
				this.btnBackgroundLarge = new IconButton(this.skin.cssSprite, this.skin.styleBtnBackgroundLarge.skinWidth, this.skin.styleBtnBackgroundLarge.skinHeight, this.skin.styleBtnBackgroundLarge.skinX, this.skin.styleBtnBackgroundLarge.skinY ); 
				
				
				this.setBtnBackground();
				
				this.addChild(this.btnBackgroundSmall);
				this.addChild(this.btnBackgroundMiddle);
				this.addChild(this.btnBackgroundLarge);
				this.btnBackgroundSmall.y = (this.skin.styleBtnBackgroundSmall.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.btnBackgroundSmall.height - this.skin.styleBtnBackgroundSmall.displayObjectY ) : this.skin.styleBtnBackgroundSmall.displayObjectY;	
				this.btnBackgroundMiddle.y = (this.skin.styleBtnBackgroundSmall.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.btnBackgroundMiddle.height - this.skin.styleBtnBackgroundSmall.displayObjectY ) : this.skin.styleBtnBackgroundSmall.displayObjectY;	
				this.btnBackgroundLarge.y = (this.skin.styleBtnBackgroundSmall.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.btnBackgroundLarge.height - this.skin.styleBtnBackgroundSmall.displayObjectY ) : this.skin.styleBtnBackgroundSmall.displayObjectY;	
				this.btnBackgroundSmall.enabled = false;
				this.btnBackgroundMiddle.enabled = false;
				this.btnBackgroundLarge.enabled = false;
				 	
			}
			
			if( this.skin.styleVolumebarMinus != null )
			{
				this.volumeMinusBtn = new IconButton(this.skin.cssSprite, this.skin.styleVolumebarMinus.skinWidth, this.skin.styleVolumebarMinus.skinHeight, this.skin.styleVolumebarMinus.skinX, this.skin.styleVolumebarMinus.skinY ); 
				this.addChild(this.volumeMinusBtn);
				this.volumeMinusBtn.y = (this.skin.styleVolumebarMinus.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.volumeMinusBtn.height - this.skin.styleVolumebarMinus.displayObjectY ) : this.skin.styleVolumebarMinus.displayObjectY;		
				this.volumeMinusBtn.addEventListener(MouseEvent.CLICK, onBtnClick );
			}
			
			if( this.skin.styleVolumebarPlus != null )
			{
				this.volumePlusBtn = new IconButton(this.skin.cssSprite, this.skin.styleVolumebarPlus.skinWidth, this.skin.styleVolumebarPlus.skinHeight, this.skin.styleVolumebarPlus.skinX, this.skin.styleVolumebarMinus.skinY ); 
				this.addChild(this.volumePlusBtn);
				this.volumePlusBtn.y = (this.skin.styleVolumebarPlus.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.volumePlusBtn.height - this.skin.styleVolumebarPlus.displayObjectY ) : this.skin.styleVolumebarPlus.displayObjectY;		
				this.volumePlusBtn.addEventListener(MouseEvent.CLICK, onBtnClick );
			}
			
			if( this.skin.styleMuteBtn != null )
			{
				this.muteBtn = new MultiIconButton(this.skin.cssSprite, this.skin.styleMuteBtn.skinWidth, this.skin.styleMuteBtn.skinHeight, this.skin.styleMuteBtn.skinX, this.skin.styleMuteBtn.skinY, this.skin.styleMuteBtn.skinPhases ); 
				this.addChild(this.muteBtn);
				this.muteBtn.y = (this.skin.styleMuteBtn.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.muteBtn.height - this.skin.styleMuteBtn.displayObjectY ) : this.skin.styleMuteBtn.displayObjectY;	
				//this.muteBtn.y -=2;
				this.muteBtn.addEventListener(MouseEvent.CLICK, onMultiIconBtnClick );
				if(this.skin.styleVolumebar && this.skin.styleVolumebar.rotation == true && this.skin.styleVolumebar.hideable == true )
				{
					this.muteBtn.addEventListener(MouseEvent.MOUSE_OVER, onShowVolumebar );
					this.muteBtn.addEventListener(MouseEvent.MOUSE_OUT, onHideVolumebar );
				}
				this.muteBtn.addEventListener(MouseEvent.CLICK, onBtnClick );
			}
			if( this.skin.styleFullscreenBtn != null )
			{
				this.fullscreenBtn = new IconButton(this.skin.cssSprite, this.skin.styleFullscreenBtn.skinWidth, this.skin.styleFullscreenBtn.skinHeight, this.skin.styleFullscreenBtn.skinX, this.skin.styleFullscreenBtn.skinY ); 
				this.addChild(this.fullscreenBtn);
				this.fullscreenBtn.y = (this.skin.styleFullscreenBtn.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.fullscreenBtn.height - this.skin.styleFullscreenBtn.displayObjectY ) : this.skin.styleFullscreenBtn.displayObjectY;	
				//this.fullscreenBtn.y -=2;
				this.fullscreenBtn.addEventListener(MouseEvent.CLICK, onBtnClick );
			}
			
			if(BildTvDefines.size == BildTvDefines.SIZE_BIG || BildTvDefines.size == BildTvDefines.SIZE_MEDIUM)
			{				
				if( this.skin.styleSubtitleBtn != null )
				{
					this.subtitleBtn = new MultiIconButton(this.skin.cssSprite, this.skin.styleSubtitleBtn.skinWidth, this.skin.styleSubtitleBtn.skinHeight, this.skin.styleSubtitleBtn.skinX, this.skin.styleSubtitleBtn.skinY, this.skin.styleSubtitleBtn.skinPhases ); 
					this.addChild(this.subtitleBtn);
					this.subtitleBtn.y = (this.skin.styleSubtitleBtn.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.subtitleBtn.height - this.skin.styleSubtitleBtn.displayObjectY ) : this.skin.styleSubtitleBtn.displayObjectY;	
					this.subtitleBtn.addEventListener(MouseEvent.CLICK, onMultiIconBtnClick );
					this.subtitleBtn.addEventListener(MouseEvent.CLICK, onBtnClick );
				}
			}
			else
			{
				this.skin.styleSubtitleBtn = null;
				this.skin.styleSubtitleBox = null;
			}
			
			if( this.skin.styleBilddeBtn != null )
			{
				this.bilddeBtn = new IconButton(this.skin.cssSprite, this.skin.styleBilddeBtn.skinWidth, this.skin.styleBilddeBtn.skinHeight, this.skin.styleBilddeBtn.skinX, this.skin.styleBilddeBtn.skinY ); 
				this.addChild(this.bilddeBtn);
				this.bilddeBtn.y = (this.skin.styleBilddeBtn.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.bilddeBtn.height - this.skin.styleBilddeBtn.displayObjectY ) : this.skin.styleBilddeBtn.displayObjectY;	
				this.bilddeBtn.addEventListener(MouseEvent.CLICK, onBtnClick );
				this.bilddeBtn.addEventListener(MouseEvent.MOUSE_OVER, onBtnClick );
				this.bilddeBtn.addEventListener(MouseEvent.MOUSE_OUT, onBtnClick );
				
				if( this.skin.styleBilddeBtnTooltip != null )
				{
					this.bilddeBtnTooltip = new IconButton(this.skin.cssSprite, this.skin.styleBilddeBtnTooltip.skinWidth, this.skin.styleBilddeBtnTooltip.skinHeight, this.skin.styleBilddeBtnTooltip.skinX, this.skin.styleBilddeBtnTooltip.skinY ); 
					this.addChild(this.bilddeBtnTooltip);
					this.bilddeBtnTooltip.enabled = false;
					this.bilddeBtnTooltip.visible = false;
					this.bilddeBtnTooltip.y = (this.skin.styleBilddeBtnTooltip.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.bilddeBtnTooltip.height - this.skin.styleBilddeBtnTooltip.displayObjectY ) : this.skin.styleBilddeBtnTooltip.displayObjectY - 5;	
				}
			}
			
			if( this.skin.styleShareBtn != null )
			{
				this.shareBtn = new IconButton(this.skin.cssSprite, this.skin.styleShareBtn.skinWidth, this.skin.styleShareBtn.skinHeight, this.skin.styleShareBtn.skinX, this.skin.styleShareBtn.skinY ); 
				this.addChild(this.shareBtn);
				this.shareBtn.y = (this.skin.styleShareBtn.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.shareBtn.height - this.skin.styleShareBtn.displayObjectY ) : this.skin.styleShareBtn.displayObjectY;	
				//this.shareBtn.y -=2;
				this.shareBtn.addEventListener(MouseEvent.CLICK, onBtnClick );
				this.shareBtn.addEventListener(MouseEvent.MOUSE_OVER, onBtnClick );
				this.shareBtn.addEventListener(MouseEvent.MOUSE_OUT, onBtnClick );
			}
			if( this.skin.styleHDBtn != null )
			{
				this.hdBtn = new MultiIconButton(this.skin.cssSprite, this.skin.styleHDBtn.skinWidth, this.skin.styleHDBtn.skinHeight, this.skin.styleHDBtn.skinX, this.skin.styleHDBtn.skinY, this.skin.styleHDBtn.skinPhases ); 
				this.addChild(this.hdBtn);
				//this.hdBtn.visible = false;
				this.hdBtn.y = (this.skin.styleHDBtn.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height - this.hdBtn.height - this.skin.styleHDBtn.displayObjectY ) : this.skin.styleHDBtn.displayObjectY;	
				this.hdBtn.addEventListener(MouseEvent.CLICK, onMultiIconBtnClick );
				this.hdBtn.addEventListener(MouseEvent.CLICK, onBtnClick );
			}	
			
							
			if( this.skin.styleProgressbar != null )
			{
				this.progressBar = new ProgressBar();
				this.addChild(this.progressBar);
				
				ct.color = this.skin.styleProgressbar.color;		
				this.progressBar.progressBar.transform.colorTransform = ct; 
				this.progressBar.progressBar.alpha = this.skin.styleProgressbar.alpha;		
				
				ct.color = this.skin.styleProgressbar.loadColor;	
				this.progressBar.preloadBar.transform.colorTransform = ct;
				this.progressBar.preloadBar.alpha = this.skin.styleProgressbar.alpha2;	 
				
				ct.color = this.skin.styleProgressbar.backgroundColor;	
				this.progressBar.background.transform.colorTransform = ct; 
				this.progressBar.background.alpha = this.skin.styleProgressbar.alpha3;	 
				
				this.progressBar.progressBar.height = this.skin.styleProgressbar.skinHeight; 
				this.progressBar.preloadBar.height 	= this.skin.styleProgressbar.skinHeight; 
				this.progressBar.seekBar.height 	= this.skin.styleProgressbar.skinHeight; 
				this.progressBar.background.height 	= this.skin.styleProgressbar.skinHeight; 
				
				this.progressBar.y = (this.skin.styleProgressbar.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM) ? (this.background.height + this.background.y - this.progressBar.background.height - this.skin.styleProgressbar.displayObjectY ) : this.skin.styleProgressbar.displayObjectY;	
				
				if( this.skin.styleProgressbarKnob != null && this.skin.styleProgressbarKnob.skinReady == true && this.skin.styleProgressbarKnob.display != "none")
				{
					var progressKnob:IconButton = new IconButton(this.skin.cssSprite, this.skin.styleProgressbarKnob.skinWidth, this.skin.styleProgressbarKnob.skinHeight, this.skin.styleProgressbarKnob.skinX, this.skin.styleProgressbarKnob.skinY ); 
					this.progressBar.playhead.addChild(progressKnob);
					//progressKnob.enabled = false;
					progressKnob.y = -((progressKnob.height - this.progressBar.progressBar.height) / 2);				
					progressKnob.x = -( progressKnob.width / 2);				
				}
				
				if( BildTvDefines.isWidgetPlayer == true )
				{
					this.progressBar.y= this.background.y + this.background.height / 2 - this.skin.styleProgressbar.skinHeight/2 ;
					this.progressbarMaskSprite = new Sprite;
					this.progressbarMaskSprite.graphics.beginFill(0xffffff);
		         	this.progressbarMaskSprite.graphics.drawRoundRect(this.skin.styleControlsbarRoot.displayObjectX, 0,300,this.skin.styleProgressbar.skinHeight, this.skin.styleProgressbar.borderRadius);
		         	this.progressbarMaskSprite.graphics.endFill(); 
		         	this.addChild(this.progressbarMaskSprite);
		         	this.progressbarMaskSprite.y = this.progressBar.y;
		         	this.progressBar.mask = this.progressbarMaskSprite;
				}
			}
			
			this.addChild( this.adControls as DisplayObject );
			
			this.adControls.y = ( this.skin.stylePlayPauseBtn.buttonAdjustVertical == SkinVO.CSS_STYLE_VERTICAL_ADJUST_BOTTOM ) ? ( - this.skin.stylePlayPauseBtn.displayObjectY + this.adControls.height ) : this.skin.stylePlayPauseBtn.displayObjectY;	
				
			if( this.skin.styleJingleControl != null ) //blank sprite over all controls
			{
				this.jingleControls.graphics.beginFill( this.skin.styleJingleControl.backgroundColor );
				this.jingleControls.graphics.drawRect( this.skin.styleJingleControl.displayObjectX, this.skin.styleJingleControl.displayObjectY, BildTvDefines.width, this.skin.styleJingleControl.skinHeight);
				this.jingleControls.graphics.endFill();
				this.addChild(this.jingleControls);
			}
			
			this.initialized = true;
			
			this.resize();
		}
		
		public function setBtnBackground():void
		{
			this.visibleButtons = 0;
			
			if( BildTvDefines.mode == BildTvDefines.MODE_EMBED )
			{
				if( this.bilddeBtn && this.bilddeBtn.visible ) this.visibleButtons++;
				this.skin.styleShareBtn = null;
			}
			else
			{
				if( this.shareBtn && this.shareBtn.visible ) this.visibleButtons++;
				this.skin.styleBilddeBtn = null;
			}
			
			if( this.hdBtn && this.hdBtn.visible ) this.visibleButtons++;
			if( this.subtitleBtn && this.subtitleBtn.visible ) this.visibleButtons++;
			if( this.fullscreenBtn && this.fullscreenBtn.visible ) this.visibleButtons++;
			if( this.muteBtn && this.muteBtn.visible ) this.visibleButtons++;
			
			
			if( this.visibleButtons <= 2 )
			{
				this.btnBackgroundSmall.visible = true;
				this.btnBackgroundMiddle.visible = false;
				this.btnBackgroundLarge.visible = false;
			}
			else if( this.visibleButtons == 3 )
			{
				this.btnBackgroundSmall.visible = false;
				this.btnBackgroundMiddle.visible = true;
				this.btnBackgroundLarge.visible = false;
			}
			else if( this.visibleButtons == 4 )
			{
				this.btnBackgroundSmall.visible = false;
				this.btnBackgroundMiddle.visible = false;
				this.btnBackgroundLarge.visible = true;
			}
		}
		
		public function onShowVolumebar(e:MouseEvent):void
		{
			if(this.volumeControl) this.volumeControl.visible = true;
		}
		public function onHideVolumebar(e:MouseEvent):void
		{
			if(this.volumeControl) 
			{
				this.volumeControl.visible = false;
				//this.volumeControl.endDrag(e);
			}
		}
		
		public function onMultiIconBtnClick(e:MouseEvent):void
		{
			e.currentTarget.phase++;
		}
		
		public function onBtnClick(e:MouseEvent):void
		{
			//trace("btn geklickt: " + e.currentTarget);
			if(e.currentTarget == this.playPauseBtn)
			{
				this.dispatchEvent( new ControlEvent( ControlEvent.PLAYPAUSE_CHANGE, null, true, true ) );		
			}
			else if(e.currentTarget == this.fullscreenBtn)
			{
				this.dispatchEvent( new ControlEvent( ControlEvent.BUTTON_CLICK, { type:ControlButton.FULLSCREEN }, true, true ) );
			}
			else if(e.currentTarget == this.shareBtn)
			{
				if( e.type == MouseEvent.MOUSE_OVER )
				{
					this.dispatchEvent( new ControlEvent( ControlEvent.BUTTON_OVER, { type:ControlButton.SHARE }, true, true ) );
				}
				if( e.type == MouseEvent.MOUSE_OUT )
				{
					this.dispatchEvent( new ControlEvent( ControlEvent.BUTTON_OUT, { type:ControlButton.SHARE }, true, true ) );
				}
			}
			else if(e.currentTarget == this.hdBtn)
			{
				this.dispatchEvent( new ControlEvent( ControlEvent.BUTTON_CLICK, { type:ControlButton.HD, phase:this.hdBtn.phase }, true, true ) );
			}
			else if(e.currentTarget == this.bilddeBtn)
			{
				if( e.type == MouseEvent.MOUSE_OVER )
				{
					this.dispatchEvent( new ControlEvent( ControlEvent.BUTTON_OVER, { type:ControlButton.BILDDE }, true, true ) );
				}
				if( e.type == MouseEvent.MOUSE_OUT )
				{
					this.dispatchEvent( new ControlEvent( ControlEvent.BUTTON_OUT, { type:ControlButton.BILDDE }, true, true ) );
				}
				if( e.type == MouseEvent.CLICK )
				{
					this.dispatchEvent( new ControlEvent( ControlEvent.BUTTON_CLICK, { type:ControlButton.BILDDE }, true, true ) );
				}
			}
			else if(e.currentTarget == this.subtitleBtn)
			{
				//this.subtitleBtn.
				this.dispatchEvent( new ControlEvent( ControlEvent.BUTTON_CLICK, { type:ControlButton.SUBTITLE }, true, true ) );
			}
			else if(e.currentTarget == this.muteBtn)
			{
				this.dispatchEvent( new ControlEvent( ControlEvent.VOLUME_CHANGE, { volume:0 }, true, true ) );
			}
			else if(e.currentTarget == this.volumeMinusBtn)
			{
				this.dispatchEvent( new ControlEvent( ControlEvent.VOLUME_CHANGE, { volume:Math.floor((this.volumeControl.volume * 10) - 1)/10 }, true, true ) );
			}
			else if(e.currentTarget == this.volumePlusBtn)
			{
				this.dispatchEvent( new ControlEvent( ControlEvent.VOLUME_CHANGE, { volume:Math.floor((this.volumeControl.volume * 10) + 1)/10  }, true, true ) );
			}
		}
		
		public function setTime( time:Number ) :void
		{
//			trace("anzeige:" + time);
			if( !BildTvDefines.isLivePlayer && !isNaN(time))
			{
				if( this.timeDisplay )
				{
					this.timeDisplay.txtTimeVideo.text = StringUtils.duration2hourminsec( time, false );
					
					if( true == this.skin.styleTimeDisplay.rotation )
					{
						this.timeDisplay.separatorMc.visible = false;
						this.timeDisplay.slashMc.visible = true;
					}
					else
					{
						this.timeDisplay.separatorMc.visible = true;
						this.timeDisplay.slashMc.visible = false;
					}		
				}	
				else if( this.timeDisplayDynamic )
				{
					if( time > 0) 
					{
						this.timeDisplayDynamic.visible = true;
					}
					
					this.timeDisplayDynamic.text = StringUtils.duration2hourminsec( time, false );	
				} 
			//this.timeDisplayDynamic.x = this.progressBar.x + this.progressBar.progressBar.width;
			}
			else if( BildTvDefines.isLivePlayer &&  BildTvDefines.isBumper )
			{
				if( this.timeDisplay )
				{
					this.timeDisplay.txtTimeVideo.text = StringUtils.duration2hourminsec( time, false );
					//this.timeDisplay.separatorMc.visible = true;
					//this.timeDisplay.slashMc.visible = true;
					this.timeDisplay.txtTimeTotal.visible = true;
				}
				if( this.timeDisplayDynamic )
				{
					this.timeDisplayDynamic.visible = true;
					this.timeDisplayDynamic.text = StringUtils.duration2hourminsec( time, false );
					
				}
			}
			
			this.resizeTimeField();
		}
		
		public function resize(fullscreenState:String = "") :void
		{	
			if( this.initialized == false ) return;
			var width:int = BildTvDefines.width;
			var playBtnPos:Number;
			var playBtnWidth:Number;
			
			if( BildTvDefines.isWidgetPlayer)
			{
				if( BildTvDefines.isLivePlayer )
				{
					if( this.playPauseBtnBackgroundLive )
					{
						playBtnPos = this.playPauseBtnBackgroundLive.x;
						playBtnWidth = this.playPauseBtnBackgroundLive.width;
					}
					else
					{
						playBtnPos = this.playPauseBtn.x;
						playBtnWidth = this.playPauseBtn.width;
					}
				}
				else
				{
					if( this.playPauseBtnBackground )
					{
						playBtnPos = this.playPauseBtnBackground.x;
						playBtnWidth = this.playPauseBtnBackground.width;
					}
					else
					{
						playBtnPos = this.playPauseBtn.x;
						playBtnWidth = this.playPauseBtn.width;
					}
				}
			}
			else
			{
				playBtnPos = this.playPauseBtn.x;
				playBtnWidth = this.playPauseBtn.width;
			}
			
			if(this.playPauseBtn) this.playPauseBtn.x = (this.skin.stylePlayPauseBtn.buttonAdjustHorizontal == SkinVO.CSS_STYLE_HORIZONTAL_ADJUST_RIGHT) ? (BildTvDefines.width - this.playPauseBtn.width - this.skin.stylePlayPauseBtn.displayObjectX ) : this.skin.stylePlayPauseBtn.displayObjectX;
			if(this.fullscreenBtn) this.fullscreenBtn.x = (this.skin.styleFullscreenBtn.buttonAdjustHorizontal == SkinVO.CSS_STYLE_HORIZONTAL_ADJUST_RIGHT) ? (BildTvDefines.width - this.fullscreenBtn.width - this.skin.styleFullscreenBtn.displayObjectX ) : this.skin.styleFullscreenBtn.displayObjectX;
			if( this.shareBtn ) this.shareBtn.x = (this.skin.styleShareBtn.buttonAdjustHorizontal == SkinVO.CSS_STYLE_HORIZONTAL_ADJUST_RIGHT) ? (BildTvDefines.width - this.shareBtn.width - this.skin.styleShareBtn.displayObjectX ) : this.skin.styleShareBtn.displayObjectX;
			if( this.subtitleBtn ) this.subtitleBtn.x = (this.skin.styleSubtitleBtn.buttonAdjustHorizontal == SkinVO.CSS_STYLE_HORIZONTAL_ADJUST_RIGHT) ? (BildTvDefines.width - this.subtitleBtn.width - this.skin.styleSubtitleBtn.displayObjectX ) : this.skin.styleSubtitleBtn.displayObjectX;
			if( this.bilddeBtn ) this.bilddeBtn.x = (this.skin.styleBilddeBtn.buttonAdjustHorizontal == SkinVO.CSS_STYLE_HORIZONTAL_ADJUST_RIGHT) ? (BildTvDefines.width - this.bilddeBtn.width - this.skin.styleBilddeBtn.displayObjectX ) : this.skin.styleBilddeBtn.displayObjectX;
			if( this.hdBtn ) this.hdBtn.x = (this.skin.styleHDBtn.buttonAdjustHorizontal == SkinVO.CSS_STYLE_HORIZONTAL_ADJUST_RIGHT) ? (BildTvDefines.width - this.hdBtn.width - this.skin.styleHDBtn.displayObjectX ) : this.skin.styleHDBtn.displayObjectX;
			if( this.muteBtn ) this.muteBtn.x = (this.skin.styleMuteBtn.buttonAdjustHorizontal == SkinVO.CSS_STYLE_HORIZONTAL_ADJUST_RIGHT) ? (BildTvDefines.width - this.muteBtn.width - this.skin.styleMuteBtn.displayObjectX ) : this.skin.styleMuteBtn.displayObjectX;
			
			if( this.playPauseBtnBackground ) this.playPauseBtnBackground.x = (this.skin.stylePlayPauseBtnBackground.buttonAdjustHorizontal == SkinVO.CSS_STYLE_HORIZONTAL_ADJUST_RIGHT) ? (BildTvDefines.width - this.playPauseBtnBackground.width - this.skin.stylePlayPauseBtnBackground.displayObjectX ) : this.skin.stylePlayPauseBtnBackground.displayObjectX;
			if( this.playPauseBtnBackgroundLive ) this.playPauseBtnBackgroundLive.x = (this.skin.stylePlayPauseBtnBackgroundLive.buttonAdjustHorizontal == SkinVO.CSS_STYLE_HORIZONTAL_ADJUST_RIGHT) ? (BildTvDefines.width - this.playPauseBtnBackgroundLive.width - this.skin.stylePlayPauseBtnBackgroundLive.displayObjectX ) : this.skin.stylePlayPauseBtnBackgroundLive.displayObjectX;
				
			if( this.btnBackgroundSmall ) this.btnBackgroundSmall.x = (this.skin.styleBtnBackgroundSmall.buttonAdjustHorizontal == SkinVO.CSS_STYLE_HORIZONTAL_ADJUST_RIGHT) ? (BildTvDefines.width - this.btnBackgroundSmall.width - this.skin.styleBtnBackgroundSmall.displayObjectX ) : this.skin.styleBtnBackgroundSmall.displayObjectX;
			if( this.btnBackgroundMiddle ) this.btnBackgroundMiddle.x = (this.skin.styleBtnBackgroundSmall.buttonAdjustHorizontal == SkinVO.CSS_STYLE_HORIZONTAL_ADJUST_RIGHT) ? (BildTvDefines.width - this.btnBackgroundMiddle.width - this.skin.styleBtnBackgroundSmall.displayObjectX ) : this.skin.styleBtnBackgroundSmall.displayObjectX;
			if( this.btnBackgroundLarge ) this.btnBackgroundLarge.x = (this.skin.styleBtnBackgroundSmall.buttonAdjustHorizontal == SkinVO.CSS_STYLE_HORIZONTAL_ADJUST_RIGHT) ? (BildTvDefines.width - this.btnBackgroundLarge.width - this.skin.styleBtnBackgroundSmall.displayObjectX ) : this.skin.styleBtnBackgroundSmall.displayObjectX;
						
			if( this.separator_1 ) this.separator_1.x = (this.skin.styleSeparator1.buttonAdjustHorizontal == SkinVO.CSS_STYLE_HORIZONTAL_ADJUST_RIGHT) ? (BildTvDefines.width - this.separator_1.width - this.skin.styleSeparator1.displayObjectX  + 5) : this.skin.styleSeparator1.displayObjectX;
			
			if( this.shareBtn )
			{
				if( this.hdBtn && this.hdBtn.visible ) this.shareBtn.x 	-= this.hdBtn.width + 5;	
			} 	
			if( this.bilddeBtn )
			{
				if( this.hdBtn && this.hdBtn.visible  ) this.bilddeBtn.x 	-= this.hdBtn.width + 5;	
			} 	
			if( this.subtitleBtn )
			{
				if( this.shareBtn && this.shareBtn.visible  ) this.subtitleBtn.x 	-= this.shareBtn.width + 5;	
				if( this.bilddeBtn && this.bilddeBtn.visible  ) this.subtitleBtn.x -= this.bilddeBtn.width + 5;	
				if( this.hdBtn && this.hdBtn.visible  ) this.subtitleBtn.x 	-= this.hdBtn.width + 5;	
			} 	
			if( this.muteBtn && false == BildTvDefines.isWidgetPlayer )
			{
				if( this.shareBtn )
				{					
					if( !BildTvDefines.preHDMode )
					{
						if( this.shareBtn.visible ) this.muteBtn.x -= this.shareBtn.width + 5;	
					}
					else
					{
						if( !BildTvDefines.isBumper ) 
						{
							if( this.shareBtn.visible ) this.muteBtn.x -= this.shareBtn.width + 11;								
						}
					}
				}
				else if( this.bilddeBtn )
				{
					if( this.bilddeBtn.visible ) this.muteBtn.x -= this.bilddeBtn.width + 5;	
				}
				else
				{				
					//trace(BildTvDefines.isWeltPlayer);
					//if( !BildTvDefines.isWeltPlayer ) this.muteBtn.x += this.fullscreenBtn.width + 5;	
				} 
				
				if( this.hdBtn )
				{
					if( this.hdBtn.visible ) this.muteBtn.x 	-= this.hdBtn.width + 5;			
					else this.muteBtn.x 	+= this.hdBtn.width + 5;
				}
				else
				{
						
				}
				
				if( this.subtitleBtn )
				{
					if( this.subtitleBtn.visible )
					{
						//this.muteBtn.x-= this.subtitleBtn.width + 5;				
					}
				}
				else
				{
					if(!this.adControls.visible && !BildTvDefines.isBumper && ( this.shareBtn || this.bilddeBtn ))
					{
						this.muteBtn.x+= this.fullscreenBtn.width + 5;		
					}
					else if( !BildTvDefines.preHDMode && !this.hdBtn )
					{
						this.muteBtn.x+= this.fullscreenBtn.width + 5;		
					}
				}
			} 	
			if( this.volumeControl )
			{
				if(this.volumeMinusBtn) this.volumeMinusBtn.x = this.muteBtn.x + 10;
				if(this.volumeControl)
				{
					if( this.volumeControlMode == VolumeControlVertical.NAME )
					{
						this.volumeControl.x = this.muteBtn.x;		
					}	
					else
					{
						this.volumeControl.x = this.muteBtn.x + this.muteBtn.width + 15;						
					}
				}
				if(this.volumePlusBtn)this.volumePlusBtn.x = this.volumeControl.x + this.volumeControl.width;	
			}
			
			if( this.separator_2 ) this.separator_2.x = this.volumeControl.x + this.volumeControl.width + 20;
			if( this.bilddeBtnTooltip ) 
			{
				this.bilddeBtnTooltip.x = this.bilddeBtn.x + this.bilddeBtn.width - this.bilddeBtnTooltip.width / 2;
				if(( this.bilddeBtnTooltip.x + this.bilddeBtnTooltip.width ) > width )
				{
					this.bilddeBtnTooltip.x = width - this.bilddeBtnTooltip.width;
				}
			}
			
			if( this.timeDisplay ) this.timeDisplay.x = (this.skin.styleTimeDisplay.buttonAdjustHorizontal == SkinVO.CSS_STYLE_HORIZONTAL_ADJUST_RIGHT) ? (BildTvDefines.width - this.timeDisplay.width - this.skin.styleTimeDisplay.displayObjectX - 20 ) : this.skin.styleTimeDisplay.displayObjectX - 20;
			
			if( this.progressBar )
			{
				if(this.skin.styleProgressbar.position == SkinVO.CSS_STYLE_POSITION_ABLOLUTE)
				{
					this.progressBar.x = 0; 
				}
				else
				{
					if( BildTvDefines.isWidgetPlayer)
					{
						if( BildTvDefines.isLivePlayer )
						{
							if( this.playPauseBtnBackgroundLive ) this.progressBar.x = this.playPauseBtnBackgroundLive.x + this.playPauseBtnBackgroundLive.width + 10;
							else this.progressBar.x = this.playPauseBtn.x + this.playPauseBtn.width + 10;
						}
						else
						{
							if( this.playPauseBtnBackground ) this.progressBar.x = this.playPauseBtnBackground.x + this.playPauseBtnBackground.width + 10;
							else this.progressBar.x = this.playPauseBtn.x + this.playPauseBtn.width + 10;
						}				
					}
					else
					{
						this.progressBar.x = this.playPauseBtn.x + this.playPauseBtn.width + 10;
					}
				}
				if( this.skin.styleProgressbar.position == SkinVO.CSS_STYLE_POSITION_ABLOLUTE )
				{
					this.progressBar.width = BildTvDefines.width;
				}
				else if( this.skin.styleProgressbar.position == SkinVO.CSS_STYLE_POSITION_RELATIVE )
				{										
					if( this.skin.styleControlsbarRoot.position == SkinVO.CSS_STYLE_POSITION_RELATIVE )
					{
						this.progressBar.width = this.timeDisplay.x - playBtnPos - playBtnWidth - 15; //toDelete is not final				
					}
					else if( this.skin.styleControlsbarRoot.position == SkinVO.CSS_STYLE_POSITION_ABLOLUTE )
					{
						if( true == this.btnBackgroundSmall.visible )
						{
							this.progressBar.width = this.btnBackgroundSmall.x - playBtnPos - playBtnWidth - 40; //toDelete is not final
						}
						if( true == this.btnBackgroundMiddle.visible )
						{
							this.progressBar.width = this.btnBackgroundMiddle.x - playBtnPos - playBtnWidth - 40; //toDelete is not final
						}
						if( true == this.btnBackgroundLarge.visible )
						{
							this.progressBar.width = this.btnBackgroundLarge.x - playBtnPos - playBtnWidth - 40; //toDelete is not final							
						}
						if( fullscreenState == "fullScreen" )
						{
							this.progressBar.width-=10;
						}	
					}
				}
				
//				trace("progBarWidth:: " + this.progressBar.width);
			} 
			
			
			if( this.progressbarMaskSprite )
			{
				this.progressBar.x = playBtnPos + playBtnWidth + 20;
				this.progressbarMaskSprite.x = this.progressBar.x;
				this.progressbarMaskSprite.width = this.progressBar.width; //toDelete   neu zeichnen um Verzerrungen zu vermeiden
			} 
			
			if( this.progressBar && this.background )
			{			
				this.background.x = (this.skin.styleControlsbarRoot.position == SkinVO.CSS_STYLE_POSITION_ABLOLUTE) ? playBtnPos + playBtnWidth + 10 : 0 ;// (this.skin.styleProgressbar.buttonAdjustHorizontal == SkinVO.CSS_STYLE_HORIZONTAL_ADJUST_RIGHT) ? (BildTvDefines.width - this.progressBar.width - this.skin.styleProgressbar.displayObjectX ) : this.skin.styleProgressbar.displayObjectX; //this.playPauseBtn.x + this.playPauseBtn.width + 10;	
				this.background.width = (this.skin.styleControlsbarRoot.position == SkinVO.CSS_STYLE_POSITION_ABLOLUTE) ? this.progressBar.width + 20 : width;	
			}
			
			if( this.adControls ) this.adControls.x = this.background.x;
					
			this.x = 0;
			this.resizeTimeField();				
		}

		protected function resizeTimeField() :void
		{			
			if( BildTvDefines.isWidgetPlayer)
			{				
			}
			else
			{
				if( this.timeDisplay )
				{
					this.timeDisplay.txtTimeVideo.x = this.playPauseBtn.x + 10;
					this.timeDisplay.slashMc.x = this.timeDisplay.txtTimeVideo.x + this.timeDisplay.txtTimeVideo.width - 3;
					this.timeDisplay.separatorMc.x = this.timeDisplay.txtTimeVideo.x + this.timeDisplay.txtTimeVideo.width + 3;
					this.timeDisplay.txtTimeTotal.x = this.timeDisplay.separatorMc.x  + 3;					
				}				
			}			
		}
	}
}