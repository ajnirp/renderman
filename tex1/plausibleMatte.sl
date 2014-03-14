/* $Revision: #1 $ $Date: 2013/07/30 $
# ------------------------------------------------------------------------------
#
# Copyright (c) 2011 Pixar Animation Studios. All rights reserved.
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

#include <stdrsl/ShadingContext.h>
#include <stdrsl/RadianceSample.h>
#include <stdrsl/SampleMgr.h>
#include <stdrsl/Lambert.h>
#include <stdrsl/Colors.h>

//  plausibleMatte:
//  A plausible diffuse material. Implements a basic amount 
//  of functionality needed to shade plausible matte materials.
//  Uses a simple Lambertian diffuse term.

class plausibleMatte (
    uniform float diffuseGain = .5;
    uniform color surfaceColor = color(1,1,1);
    uniform float displacementAmount = 0;
    uniform string surfaceMap = "";
    uniform string displacementMap = "";
    uniform float indirectDiffuseSamples = 64;
    uniform float indirectDiffuseMaxVar = .02;
    uniform float indirectDiffuseMaxDistance = 1e10;
    uniform float minMaterialSamples = 0;
    uniform float maxMaterialSamples = 0;
    uniform string lightCategory = "";
    uniform float applySRGB = 1;
    uniform string causticMap = "";
    uniform float photonEstimator = 100;
    uniform float __computesOpacity = 0;
    )
{
    // Member variables
    stdrsl_ShadingContext m_shadingCtx;
    stdrsl_Lambert m_diffuse;
    stdrsl_Fresnel m_fresnel; // unused

    public void construct() 
    {
        m_shadingCtx->construct();
    }

    public void begin() 
    {
    }

    public void displacement(output point P;output normal N) 
    {
        if(displacementMap != "" && displacementAmount != 0) 
        {
            float displacementValue = 
                displacementAmount * texture(displacementMap[0]);
            m_shadingCtx->displace(vector(normalize(N)), displacementValue,
                                    "displace");
        }
        m_shadingCtx->init();
    }


    public void prelighting(output color Ci,Oi) 
    {
    }

    public void diffuselighting(output color Ci, Oi) 
    {
        color diffColor = surfaceColor * diffuseGain * Cs;
        if(surfaceMap!= "")
        {
            color c = color texture(surfaceMap);
            if(applySRGB != 0) c = srgbToLinear(c);
            diffColor *= c;
        }
        m_diffuse->init(m_shadingCtx,diffColor,minMaterialSamples,maxMaterialSamples);

        uniform float diffuseMIS = 0;
        if (m_diffuse->m_sampleCount > 0) diffuseMIS = 1;

        Ci = directlighting(this, getlights("category",lightCategory),
                                "diffusemis",diffuseMIS
                                );

        // Reduce the number of indirect samples based on diffuse ray depth
        if(indirectDiffuseSamples > 0) 
        {
            uniform float idiffSamps, idiffMaxVar;
            m_shadingCtx->m_SampleMgr->computeIndirectDiffuseSamples(
                                                 indirectDiffuseSamples,
                                                 indirectDiffuseMaxVar,
                                                 idiffSamps, idiffMaxVar);

            Ci +=  diffColor * indirectdiffuse(P, m_shadingCtx->m_Ns,
                                    idiffSamps,
                                    "maxvariation", idiffMaxVar,
                                    "maxdist", indirectDiffuseMaxDistance);
        }

        if (causticMap != "") 
        {
            Ci += diffColor * photonmap(causticMap, P, m_shadingCtx->m_Ns,
                                        "estimator", photonEstimator);
        }
    }

    public void evaluateSamples(string distribution;
                                output __radiancesample samples[])
    {
        if (distribution == "diffuse") {
            m_diffuse->evalDiffuseSamps(m_shadingCtx, m_fresnel, samples);    
    }
}
    
    public void generateSamples(string type;
                                output __radiancesample samples[])
    {
        if (type == "diffuse" || type == "diffusespecular")
            m_diffuse->genDiffuseSamps(m_shadingCtx, m_fresnel, samples);
    }
}
