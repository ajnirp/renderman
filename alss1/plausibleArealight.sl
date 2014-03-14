/* $Revision: #1 $ $Date: 2013/07/30 $
# ------------------------------------------------------------------------------
#
# Copyright (c) 2011-2012 Pixar Animation Studios. All rights reserved.
#
# The information in this file is provided for the exclusive use of the
# software licensees of Pixar.  It is UNPUBLISHED PROPRIETARY SOURCE CODE
# of Pixar Animation Studios; the contents of this file may not be disclosed
# to third parties, copied or duplicated in any form, in whole or in part,
# without the prior written permission of Pixar Animation Studios.
# Use of copyright notice is precautionary and does not imply publication.
#
# PIXAR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
# ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT
# SHALL PIXAR BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES
# OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
# WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
# ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
# SOFTWARE.
#
# Pixar
# 1200 Park Ave
# Emeryville CA 94608
#
# ------------------------------------------------------------------------------
*/

#include <stdrsl/ShadingContext.h> // for ShadingUtils
#include <stdrsl/AreaSampler.h>
#include <stdrsl/SampleMgrPathTrace.h>

class
plausibleArealight(
    float intensity = 1;
    color lightcolor = 1;
    float minSamples = 16;
    float maxSamples = 100;
    float sides = 1;
    float adaptiveshadow = 1;
    string shadowname = "";
    string mapname = "";
    string shape = "rect";
    float bias = 0.007;
    float mapbias = 1;
    float mapbias2 = 5;
    float hybridshadows = 1;
    float areanormalize = 0;
    string __category = "stdrsl_plausible";
)
{
    varying normal m_Ns;
    stdrsl_SampleMgrPathTrace m_sampleMgr;

    public void light(output vector L; output color Cl;)
    {
        // dummy method signals that this class is intended for use as light
        L = 0; Cl = 0;
    }

    public void prelighting(output color Ci, Oi) {
        color lc = intensity * lightcolor;
        if (mapname == "") {
            emit(lc,
                    "areanormalized", areanormalize,
                    "raytraceshadows", 1, 
                    "shadowbias", bias,
                    "adaptiveshadow", adaptiveshadow,
                    "shadowmapbias", mapbias,
                    "shadowmapbias2", mapbias2);
        } 
        else 
        {
            emit(lc * texture(mapname),
                    "areanormalized", areanormalize,
                    "raytraceshadows", 1, 
                    "shadowbias", bias,
                    "adaptiveshadow", adaptiveshadow,
                    "shadowmapbias", mapbias,
                    "shadowmapbias2", mapbias2);
        }
    }

    public void construct()
    {
        m_sampleMgr->construct();
    }

    public void begin()
    {
        m_sampleMgr->begin();
        uniform float raydepth, diffusedepth;
        uniform float sides;
        rayinfo("depth", raydepth);
        attribute("Sides", sides);

        // We need to agree with surface over the definition of the
        // lighting hemisphere. This is captured in m_Ns.
        normal nn, nf;
        vector in;
        stdrsl_ShadingUtils sutils;
        sutils->GetShadingVars(raydepth, sides, nn, in, nf, m_Ns);
    }

    public void generateSamples(string integrationdomain;
                                output __radiancesample rsamples [])
    {
        // rsamples needs to be filled out with our colors at each position.
        // We use stdrsl_AreaSampler to generate samples and provide us with
        // with an estimate of the pdf based on the size of the sample.
        // sampler sets lightPdf to negative if light sample points
        // away from us. We cannot set the pdf to zero if it's a valid sample 
        // but has no contribution, otherwise integrator would normalize by 
        // the wrong number of samples.
        stdrsl_AreaSampler sampler;
        uniform float nsamples;
        m_sampleMgr->computeLightSamples(minSamples, maxSamples, nsamples);
        sampler->generateSamples(Ps, shape, nsamples, rsamples);
        
        color lc = intensity * lightcolor;
        uniform float i, alen = arraylength(rsamples);
        for(i=0;i<alen;i+=1)
        {
            if(rsamples[i]->lightPdf > 0)
            {
                if (integrationdomain == "hemisphere" && 
                    rsamples[i]->direction.m_Ns <= 0)
                {
                    // This sample is below the horizon, no contribution.
                    // Leave pdf untouched.
                    rsamples[i]->radiance = color(0);
                }
                else 
                {
                    
                    varying color st = rsamples[i]->radiance;
                    if(mapname != "") 
                    {
                        rsamples[i]->radiance = lc * texture(mapname,
                                                             st[0], st[1],
                                                             st[0], st[1],
                                                             st[0], st[1],
                                                             st[0], st[1]);
                    } 
                    else
                        rsamples[i]->radiance = lc;
                }
            }
            else
            if(rsamples[i]->lightPdf < 0)
            {
                // the AreaSampler has signaled us that the sampler hits
                // the back side of our light shape.
                if(sides != 1)
                   rsamples[i]->radiance = lc;
                else
                    rsamples[i]->radiance = color(0);
                rsamples[i]->lightPdf *= -1;
            }
            else
            {
                print("this shouldn't occur: why generate samples with pdf");
            }
        }
    }

    public void evaluateSamples(string integrationdomain;
                                output __radiancesample rsamples[])
    {
        stdrsl_AreaSampler sampler;
        sampler->evaluateSamples(Ps, shape, rsamples);
        uniform float i, alen = arraylength(rsamples);
        color lc = intensity * lightcolor;
        for(i=0;i<alen;i+=1)
        {
            if(rsamples[i]->lightPdf > 0)
            {
                if(integrationdomain == "hemisphere" &&
                    rsamples[i]->direction.m_Ns <= 0)
                {
                    // This sample is below the horizon, no contribution.
                    // Leave pdf untouched.
                    rsamples[i]->radiance = color(0);
                }
                else
                {
                    varying color st = rsamples[i]->radiance;
                    if(mapname != "") {
                        rsamples[i]->radiance = lc * texture(mapname,
                                                             st[0], st[1],
                                                             st[0], st[1],
                                                             st[0], st[1],
                                                             st[0], st[1]);
                    } else {
                        rsamples[i]->radiance = lc;
                    }
                    
                }
            }
            else
            if(rsamples[i]->lightPdf <  0)
            {
                if(sides != 1)
                    rsamples[i]->radiance = lc;
                else
                    rsamples[i]->radiance = color(0);
                rsamples[i]->lightPdf *= -1;
            }
            // else lightPdf == 0, nothing to do
        }
    }

    public void shadowSamples(output __radiancesample samples[]) 
    {
        filterregion fr;
        fr->calculate3d(Ps);		
        if (shadowname == "") 
        {
            areashadow("", fr, samples, 
                      "raytrace", 1, 
                      "bias", bias,
                      "adaptive", adaptiveshadow);
        } 
        else 
        {
            areashadow(shadowname, fr, samples,
                    "raytrace", hybridshadows, 
                    "bias", bias, 
                    "mapbias", mapbias,
                    "mapbias2", mapbias2);
        }
    }

    public void generatePhoton(output point origin; output vector direction;
                               output color power; output float pdf)
    {
        // Use stdrsl_AreaSampler to generate a photon origin, direction,
        // texture sample coordinates, and light source area
        stdrsl_AreaSampler sampler;
        float ss, tt, lightarea;
        sampler->generatePhoton(shape, sides,
                                origin, direction, ss, tt, lightarea);

        color lc = intensity * lightcolor;
        if (mapname != "") {
            color tex = texture(mapname, ss, tt, ss, tt, ss, tt, ss, tt);
            lc *= tex;
        }
        // Compute power of light source and assign pdf
        power = lc * lightarea;
        pdf = intensity * lightarea;
    }

}

