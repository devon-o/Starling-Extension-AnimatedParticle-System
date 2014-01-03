package 
{
    
import flash.display.Sprite;
import flash.events.Event;
import starling.core.Starling;
import starling.display.Sprite;
import starling.extensions.AnimatedPDParticleSystem;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

/**
 * Example of animated particle system
 * @author Devon O.
 */

[SWF(width='800', height='600', backgroundColor='#000072', frameRate='60')]
public class Main extends flash.display.Sprite 
{
    
    [Embed(source="assets/starling_bird.png")]
    private static const BIRD_ATLAS:Class;
    
    [Embed(source = "assets/starling_bird.xml", mimeType = "application/octet-stream")]
    private static const BIRD_DESCRIPTOR:Class;
    
    [Embed(source = "assets/particleConfig.pex", mimeType = "application/octet-stream")]
    private static const PARTICLE_CONFIG:Class;
    
    private var sRoot:starling.display.Sprite;
    
    public function Main():void 
    {
        if (stage) init();
        else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event = null):void 
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        
        initStarling();
    }
    
    private function initStarling():void
    {
        var s:Starling = new Starling(starling.display.Sprite, stage);
        s.addEventListener("rootCreated", onStarlingRoot);
        s.start();
    }
    
    private function onStarlingRoot(e:*):void
    {
        var s:Starling = e.currentTarget as Starling;
        s.removeEventListener("rootCreated", onStarlingRoot);
        this.sRoot = s.root as starling.display.Sprite;
        s.showStats = true;
        
        initParticles();
    }
    
    private function initParticles():void
    {
        var desc:XML = XML(new BIRD_DESCRIPTOR());
        var atlas:TextureAtlas = new TextureAtlas(Texture.fromBitmap(new BIRD_ATLAS()), desc);
        var pCfg:XML = XML(new PARTICLE_CONFIG());
        var ps:AnimatedPDParticleSystem = new AnimatedPDParticleSystem(pCfg, atlas, 30);
        ps.emitterX = -20;
        ps.emitterY = stage.stageHeight * .60;
        this.sRoot.addChild(ps);
        Starling.current.juggler.add(ps);
        ps.start();
    }
    
}
	
}