// =================================================================================================
//
//	Starling Framework - Particle System Extension
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
//  Modified for animation by Devon O. Wolfgang 2013
// =================================================================================================

package starling.extensions
{
    import flash.geom.Rectangle;
    import starling.animation.IAnimatable;
    import starling.textures.TextureAtlas;
    
    public class AnimatedPDParticle extends PDParticle implements IAnimatable
    {
        public var frameNum:int=0;
        public var startFrame:int=-1;
        public var regions:Vector.<Rectangle>;
        
        private var frameDuration:Number;
        private var frameTime:Number = 0.0;
        
        public function AnimatedPDParticle(atlas:TextureAtlas, fps:int=12, animationPrefix:String="")
        {
            super();
            
            parseAtlas(atlas, animationPrefix);
            
            this.frameDuration = 1 / fps;
        }
        
        public function advanceTime(time:Number):void
        {
            this.frameTime += time;
            if (this.frameTime >= frameDuration)
            {
                if (++this.frameNum == this.regions.length)
                    this.frameNum = 0;
                    
                this.frameTime = 0.0;
            }
        }
        
        private function parseAtlas(atlas:TextureAtlas, animationPrefix:String):void
        {
            this.regions = new Vector.<Rectangle>();
            var names:Vector.<String> = atlas.getNames(animationPrefix);
            for each(var name:String in names)
            {
                this.regions.push(atlas.getRegion(name));
            }
            
            this.regions.fixed = true;
        }
    }
}