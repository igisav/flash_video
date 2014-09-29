/*
 @author: Igor Savchenko
 Axel Springer ideAS Engineering GmbH
 */

package de.axelspringer.videoplayer.controller
{
    import flash.display.Sprite;
    import flash.media.SoundTransform;

    import flash.utils.getDefinitionByName;

    import org.osmf.containers.MediaContainer;
    import org.osmf.events.LoadEvent;
    import org.osmf.events.MediaErrorEvent;
    import org.osmf.events.MediaFactoryEvent;
    import org.osmf.events.TimeEvent;
    import org.osmf.layout.HorizontalAlign;
    import org.osmf.layout.LayoutMetadata;
    import org.osmf.layout.ScaleMode;
    import org.osmf.layout.VerticalAlign;
    import org.osmf.media.DefaultMediaFactory;
    import org.osmf.media.MediaElement;
    import org.osmf.media.MediaFactory;
    import org.osmf.media.MediaPlayer;
    import org.osmf.media.MediaResourceBase;
    import org.osmf.media.PluginInfoResource;
    import org.osmf.media.URLResource;
    import org.osmf.net.DynamicStreamingResource;
    import org.osmf.net.MulticastResource;
    import org.osmf.net.StreamType;
    import org.osmf.net.StreamingURLResource;
    import org.osmf.traits.LoadState;
    import org.osmf.traits.LoadTrait;
    import org.osmf.traits.MediaTraitType;
    import org.osmf.traits.PlayTrait;
    import org.osmf.utils.Version;

    /* This class is for testing of OSMF and Akamai Plugin.
     Not finished right now
     */
    public class OSMFPlayer implements IVideoPlayer
    {
        //private var view:MediaPlayerSprite;
        protected var soundTransform:SoundTransform = new SoundTransform();

        private var lastVolumeValue:Number = 0;
        private var stage:Sprite;

        private var container:MediaContainer = new MediaContainer();
        private var mediaPlayer:MediaPlayer = new MediaPlayer();
        private var mediaFactory:MediaFactory = new DefaultMediaFactory();

        public function OSMFPlayer(stage:Sprite) {
            trace("OSMF Version", Version.version, Version.buildNumber);

            this.stage = stage;

            /*var s:Sprite = new Sprite();
             s.graphics.beginFill(0xf00);
             s.graphics.drawRect(0,0,100,100);
             s.graphics.endFill();
             stage.addChild(s);*/
        }

        public function loadURL(streamUrl:String):void {
            trace(this + "loadURL: " + streamUrl);

            var currentVideo:String;

            // braucht Authorisierung
            // currentVideo = "rtmp://pssimn24livefs.fplive.net/pssimn24live-live/stream1";
            // currentVideo = "rtmp://pssimn24livefs.fplive.net/pssimn24live-live/n24livestream1/n24livestream1";

            // geht nicht
            currentVideo = "rtmp://cp67126.edgefcs.net/ondemand/&mp4:mediapm/ovp/content/test/video/spacealonehd_sounas_640_300.mp4";
            currentVideo = "rtmpe://cp134706.live.edgefcs.net/live/demostream_1_1200@2131";

            // geht mit StreamingURLResource
            currentVideo = "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short";
            currentVideo = "rtmp://cp88082.edgefcs.net/ondemand/mp4:trailer/72041_46322.flv";
            // geht mit StreamingURLResource + StreamType.LIVE
            currentVideo = "rtmp://rtmp.jim.stream.vmmacdn.be/vmma-jim-rtmplive-live/jim";

            // geht mit DynamicStreamingResource und MediaFactory
            currentVideo = "http://multiplatform-f.akamaihd.net/z/multi/companion/big_bang_theory/big_bang_theory.mov_,300,600,800,1000,2500,4000,9000,k.mp4.csmil/manifest.f4m";

            // geht mit MulticastResource und MediaFactory
            currentVideo = "rtmp://cp121363.live.edgefcs.net/live/hr-fernsehen_768@53002";

            // currentVideo = "http://hds.ak.token.bild.de/31063808,delivery=hds.f4m";
            // var currentVideo = "http://videos-world.ak.token.bild.de/BILD/34/75/04/76/34750476,property=Video.mp4";

            /*loadPlugin("http://players.edgesuite.net/flash/plugins/osmf/advanced-streaming-plugin/fp10.1/current/AkamaiAdvancedStreamingPlugin.swf");
             return;*/

            /*var sprite:MediaPlayerSprite = new MediaPlayerSprite();

             addChild(sprite);
             sprite.width = 640;
             sprite.height = 360;
             //sprite.resource = new StreamingURLResource(currentVideo, StreamType.LIVE);

             var videoElement:VideoElement = new VideoElement();
             videoElement.resource = new StreamingURLResource(currentVideo, StreamType.LIVE);
             sprite.media = videoElement;*/

            //var container:MediaContainer = new MediaContainer();
            container.width = stage.width;
            container.height = stage.height;
            stage.addChild(container);

            var urlResource:URLResource = new URLResource(currentVideo);
            var streamingResource:StreamingURLResource = new StreamingURLResource(currentVideo, StreamType.RECORDED);
            var multiResource:MulticastResource = new MulticastResource(currentVideo);
            var dynResource:DynamicStreamingResource = new DynamicStreamingResource(currentVideo);

            var mediaElement:MediaElement = mediaFactory.createMediaElement(multiResource);
            //var mediaElement:MediaElement = new VideoElement( streamingResource );

            var layoutMetadata:LayoutMetadata = new LayoutMetadata();
            layoutMetadata.scaleMode = ScaleMode.NONE;
            layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
            layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
            mediaElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);

            container.addMediaElement(mediaElement);

            mediaPlayer.autoPlay = true;
            mediaPlayer.media = mediaElement;
            mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onTimeUpdated);
            mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, onTimeUpdated);
            mediaPlayer.addEventListener(MediaErrorEvent.MEDIA_ERROR, onError);
        }

        private static const AKAMAI_BASIC_STREAMING_PLUGIN_INFO:String = "com.akamai.osmf.AkamaiBasicStreamingPluginInfo";

        private function loadAkamai():void {
            //var s:com.akamai.osmf.AkamaiBasicStreamingPluginInfo = new AkamaiBasicStreamingPluginInfo();
            mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);

            var pluginInfoRef:Class = flash.utils.getDefinitionByName(AKAMAI_BASIC_STREAMING_PLUGIN_INFO) as Class;
            var pluginResource:MediaResourceBase = new PluginInfoResource(new pluginInfoRef);
            mediaFactory.loadPlugin(pluginResource);
            trace("try to load");
        }

        private function onPluginLoaded(event:MediaFactoryEvent):void {
            trace("plugin is loaded");
            var url:String = "http://hds.ak.token.bild.de/31063808,delivery=hds.f4m";
            var urlResource:URLResource = new URLResource(url);
            var mediaElement:MediaElement = mediaFactory.createMediaElement(urlResource);

            var loadTrait:LoadTrait = mediaElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
            loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onElementLoadStateChange);
            loadTrait.load();

            function onElementLoadStateChange(event:LoadEvent):void {
                if (event.loadState == LoadState.READY)
                {
                    var playTrait:PlayTrait = mediaElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
                    mediaElement.addEventListener(MediaErrorEvent.MEDIA_ERROR, onError, false, 0, true);
                    playTrait.play();

                    trace("load akamai complete");
                }
                else if (event.loadState == LoadState.LOAD_ERROR)
                {
                    trace("load akamai fehler");
                }
            }
        }

        public function loadPlugin(source:String):void {
            var pluginResource:MediaResourceBase;
            if (source.substr(0, 4) == "http" ||
                    source.substr(0, 4) == "file")
            {
                pluginResource = new URLResource(source);
            }
            else
            {
                var pluginInfoRef:Class = flash.utils.getDefinitionByName(source)
                        as Class;
                pluginResource = new PluginInfoResource(new pluginInfoRef);
            }


            loadPluginFromResource(pluginResource);
        }

        private function loadPluginFromResource(pluginResource:MediaResourceBase):void {
            setupListeners();
            mediaFactory.loadPlugin(pluginResource);
            function setupListeners(add:Boolean = true):void {
                if (add)
                {
                    mediaFactory.addEventListener(
                            MediaFactoryEvent.PLUGIN_LOAD,
                            onPluginLoad);
                    mediaFactory.addEventListener(
                            MediaFactoryEvent.PLUGIN_LOAD_ERROR,
                            onPluginLoadError);
                }
                else
                {
                    mediaFactory.removeEventListener(
                            MediaFactoryEvent.PLUGIN_LOAD,
                            onPluginLoad);
                    mediaFactory.removeEventListener(
                            MediaFactoryEvent.PLUGIN_LOAD_ERROR,
                            onPluginLoadError);
                }
            }

            function onPluginLoad(event:MediaFactoryEvent):void {
                trace("plugin loaded successfully.");
                setupListeners(false);
            }

            function onPluginLoadError(event:MediaFactoryEvent):void {
                trace("plugin failed to load.");
                setupListeners(false);
            }
        }

        protected static function onError(e:MediaErrorEvent):void {
            trace("Error:", e.error.detail, e.error.message);
        }

        private function onTimeUpdated(event:TimeEvent):void {
            trace('time: ' + mediaPlayer.currentTime + ' duration: ' + mediaPlayer.duration + " buffering=" + mediaPlayer.buffering
                    + " buffer=" + mediaPlayer.bufferLength);
        }

        /********************************************************************************************************
         * EXTERNAL CALLBACKS
         *******************************************************************************************************/

        public function play():void {

        }

        public function volume(value:Number = NaN):Number {
            if (!isNaN(value))
            {
            }

            return this.soundTransform ? this.soundTransform.volume : 0
        }

        public function muted(value:String = ""):Boolean {
            if (value != "")
            {
                var muteValue:Number = value == "false" ? lastVolumeValue : 0;
                volume(muteValue);
            }

            return this.soundTransform.volume == 0
        }

        public function pause():void {
        }

        public function currentTime(seekPoint:Number = NaN):Number {
            return 0;
        }


        public function getDuration():String {
            return "0"
        }

        public function getBufferTime():Number {
            return 0;
        }

        public function enableHD(value:String = ""):void {
            // nothing here. implementation of interface
        }

        public function destroy():void {
        }

        /********************************************************************************************************
         * END OF EXTERNAL CALLBACKS
         *******************************************************************************************************/


    }
}