/**
 *	Copyright (c) 2014 Devon O. Wolfgang
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to deal
 *	in the Software without restriction, including without limitation the rights
 *	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *	copies of the Software, and to permit persons to whom the Software is
 *	furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in
 *	all copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *	THE SOFTWARE.
 */

package starling.extensions 
{

import flash.geom.Rectangle;
import starling.events.Event;
import starling.textures.TextureAtlas;

/**
 * AnimatedPDParticleSystem is a PDParticleSystem with a particle created from an animation contained inside a TextureAtlas instance
 * @author Devon O.
 */

public class AnimatedPDParticleSystem extends OpenPDParticleSystem
{
    
    private var atlas:TextureAtlas;
    private var fps:int;
    private var startFrame:int;
    private var animationPrefix:String;
    
    /**
     * Creates an AnimatedPDParticleSystem
     * @param config            particle configuration file (XML from .pex file)
     * @param atlas             TextureAtlas containing animation
     * @param fps               Desired frames per second
     * @param startFrame        Frame number the animation should begin on. First frame is 0. Passing -1 will start animation on random frame
     * @param animationPrefix   Name of animation in Atlas. An empty String will use the entire atlas.
     */
    public function AnimatedPDParticleSystem(config:XML, atlas:TextureAtlas, fps:int=12, startFrame:int=-1, animationPrefix:String="") 
    {
        this.atlas = atlas;
        this.fps = fps;
        this.startFrame = startFrame;
        this.animationPrefix = animationPrefix;
        
        super(config, this.atlas.texture);
    }
    
    /**
     * Dispose (including the particle TextureAtlas).
     */
    public function disposeWithAtlas():void
    {
        this.atlas.dispose();
        super.dispose();
    }
    
    override protected function createParticle():Particle
    {
        var p:AnimatedPDParticle = new AnimatedPDParticle(this.atlas, this.fps, this.animationPrefix);
        p.startFrame = this.startFrame;
        return p;
    }
    
    override protected function initParticle(aParticle:Particle):void 
    {
        super.initParticle(aParticle);
        
        var ap:AnimatedPDParticle = aParticle as AnimatedPDParticle;
        if (ap.startFrame == -1)
            ap.frameNum = int(Math.random() * ap.regions.length);
        else 
            ap.frameNum = ap.startFrame;

    }
    
    override protected function advanceParticle(aParticle:Particle, passedTime:Number):void 
    {
        super.advanceParticle(aParticle, passedTime);
        
        var ap:AnimatedPDParticle = aParticle as AnimatedPDParticle;
        ap.advanceTime(passedTime);
    }
    
    override public function advanceTime(passedTime:Number):void 
    {
        var particleIndex:int = 0;
        var particle:AnimatedPDParticle;
        
        // advance existing particles
        
        while (particleIndex < mNumParticles)
        {
            particle = mParticles[particleIndex] as AnimatedPDParticle;
            
            if (particle.currentTime < particle.totalTime)
            {
                advanceParticle(particle, passedTime);
                ++particleIndex;
            }
            else
            {
                if (particleIndex != mNumParticles - 1)
                {
                    var nextParticle:Particle = mParticles[int(mNumParticles-1)] as Particle;
                    mParticles[int(mNumParticles-1)] = particle;
                    mParticles[particleIndex] = nextParticle;
                }
                
                --mNumParticles;
                
                if (mNumParticles == 0 && mEmissionTime == 0)
                    dispatchEvent(new Event(Event.COMPLETE));
            }
        }
        
        // create and advance new particles
        
        if (mEmissionTime > 0)
        {
            var timeBetweenParticles:Number = 1.0 / mEmissionRate;
            mFrameTime += passedTime;
            
            while (mFrameTime > 0)
            {
                if (mNumParticles < mMaxCapacity)
                {
                    if (mNumParticles == capacity)
                        raiseCapacity(capacity);
                
                    particle = mParticles[mNumParticles] as AnimatedPDParticle;
                    initParticle(particle);
                    
                    // particle might be dead at birth
                    if (particle.totalTime > 0.0)
                    {
                        advanceParticle(particle, mFrameTime);
                        ++mNumParticles
                    }
                }
                
                mFrameTime -= timeBetweenParticles;
            }
            
            if (mEmissionTime != Number.MAX_VALUE)
                mEmissionTime = Math.max(0.0, mEmissionTime - passedTime);
        }
        
        // update vertex data
        
        var vertexID:int = 0;
        var color:uint;
        var alpha:Number;
        var rotation:Number;
        var x:Number, y:Number;
        var xOffset:Number, yOffset:Number;
        var textureWidth:Number = mTexture.width;
        var textureHeight:Number = mTexture.height;
        var region:Rectangle;
        
        for (var i:int=0; i<mNumParticles; ++i)
        {
            vertexID = i << 2;
            particle = mParticles[i] as AnimatedPDParticle;
            region = particle.regions[particle.frameNum];
            color = particle.color;
            alpha = particle.alpha;
            rotation = particle.rotation;
            x = particle.x;
            y = particle.y;
            xOffset = region.width  * particle.scale >> 1;
            yOffset = region.height * particle.scale >> 1;
            
            for (var j:int=0; j<4; ++j)
                mVertexData.setColorAndAlpha(vertexID+j, color, alpha);
            
            // Set the texture coordinates to display only the current region
            mVertexData.setTexCoords(vertexID, region.x / textureWidth, region.y / textureHeight);
            mVertexData.setTexCoords(vertexID + 1, (region.x + region.width) / textureWidth, region.y / textureHeight);
            mVertexData.setTexCoords(vertexID + 2, region.x / textureWidth, (region.y + region.height) / textureHeight);
            mVertexData.setTexCoords(vertexID + 3, (region.x + region.width) / textureWidth, (region.y + region.height) / textureHeight);
            
            if (rotation)
            {
                var cos:Number  = Math.cos(rotation);
                var sin:Number  = Math.sin(rotation);
                var cosX:Number = cos * xOffset;
                var cosY:Number = cos * yOffset;
                var sinX:Number = sin * xOffset;
                var sinY:Number = sin * yOffset;
                
                mVertexData.setPosition(vertexID,   x - cosX + sinY, y - sinX - cosY);
                mVertexData.setPosition(vertexID+1, x + cosX + sinY, y + sinX - cosY);
                mVertexData.setPosition(vertexID+2, x - cosX - sinY, y - sinX + cosY);
                mVertexData.setPosition(vertexID+3, x + cosX - sinY, y + sinX + cosY);
            }
            else 
            {
                // optimization for rotation == 0
                mVertexData.setPosition(vertexID,   x - xOffset, y - yOffset);
                mVertexData.setPosition(vertexID+1, x + xOffset, y - yOffset);
                mVertexData.setPosition(vertexID+2, x - xOffset, y + yOffset);
                mVertexData.setPosition(vertexID + 3, x + xOffset, y + yOffset); 
            }
        }
    }
}

}