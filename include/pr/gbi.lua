-- Derived from https://github.com/sm64js/sm64js/blob/a4b809b055119b1c716f25610a59543bc9e6b2a2/src/include/gbi.js
-- FUN FACT: Lua has a hardcoded limit of 200 local variables. I found that out while making this file.

-----BEGIN SM64JS DERIVED CODE-----
-- graphics opcodes
G_MTX = 1
G_POPMTX = 2
G_MOVEMEM = 3
G_MOVEWORD = 4
G_TEXTURE = 5
G_VTX = 6
G_DL = 7
G_ENDDL = 8
G_SETGEOMETRYMODE = 9
G_CLEARGEOMETRYMODE = 10
G_TRI1 = 11
G_SETOTHERMODE_L = 12
G_SETOTHERMODE_H = 13
G_SETTIMG = 14
G_LOADBLOCK = 15
G_SETTILE = 16
G_SETTILESIZE = 17
G_LOADTLUT = 18
G_SETENVCOLOR = 19
G_SETPRIMCOLOR = 20
G_SETFOGCOLOR = 21
G_SETFILLCOLOR = 22
G_SETCOMBINE = 23
G_TEXRECTFLIP = 24
G_FILLRECT = 25
G_SETSCISSOR = 26
G_SETZIMG = 27
G_SETCIMG = 28
G_RDPLOADSYNC = 29
G_TEXRECT = 30

-- Custom Opcodes
G_SETPLAYERDATA = 30

G_ZBUFFER = 0x00000001
G_SHADE = 0x00000004
G_TEXTURE_ENABLE = 0x00000002
G_SHADING_SMOOTH = 0x00000200
G_CULL_FRONT = 0x00001000
G_CULL_BACK = 0x00002000
G_FOG = 0x00010000
G_LIGHTING = 0x00020000
G_TEXTURE_GEN = 0x00040000
G_TEXTURE_GEN_LINEAR = 0x00080000
G_CLIPPING = 0x00000000
G_CULL_BOTH = 0x00003000
G_LOD = 0x00100000

G_ON = 1
G_OFF = 0

-- flags to inhibit pushing of the display list (on branch)
G_DL_PUSH = 0x00
G_DL_NOPUSH = 0x01

G_TEXTURE_IMAGE_FRAC = 2
G_TEXTURE_SCALE_FRAC = 16
G_SCALE_FRAC = 8
G_ROTATE_FRAC = 16

-- G_SETOTHERMODE_L sft: shift count
G_MDSFT_ALPHACOMPARE = 0
G_MDSFT_ZSRCSEL = 2
G_MDSFT_RENDERMODE = 3
G_MDSFT_BLENDER = 16

-- G_SETOTHERMODE_H sft: shift count
G_MDSFT_BLENDMASK = 0 -- unsupported
G_MDSFT_ALPHADITHER = 4
G_MDSFT_RGBDITHER = 6

G_MDSFT_COMBKEY = 8
G_MDSFT_TEXTCONV = 9
G_MDSFT_TEXTFILT = 12
G_MDSFT_TEXTLUT = 14
G_MDSFT_TEXTLOD = 16
G_MDSFT_TEXTDETAIL = 17
G_MDSFT_TEXTPERSP = 19
G_MDSFT_CYCLETYPE = 20
G_MDSFT_COLORDITHER = 22 -- unsupported in HW 2.0
G_MDSFT_PIPELINE = 23

-- G_SETOTHERMODE_H gPipelineMode
G_PM_1PRIMITIVE = 1
G_PM_NPRIMITIVE = 0

-- G_SETOTHERMODE_H gSetCycleType
G_CYC_1CYCLE = 0
G_CYC_2CYCLE = 1
G_CYC_COPY = 2
G_CYC_FILL = 3

-- G_SETOTHERMODE_H gSetTexturePersp
G_TP_NONE = 0
G_TP_PERSP = 1

-- G_SETOTHERMODE_H gSetTextureDetail
G_TD_CLAMP = 0
G_TD_SHARPEN = 1
G_TD_DETAIL = 2

-- G_SETOTHERMODE_H gSetTextureLOD
G_TL_TILE = 0
G_TL_LOD = 1

-- G_SETOTHERMODE_H gSetTextureLUT
G_TT_NONE = 0
G_TT_RGBA16 = 2
G_TT_IA16 = 3

-- G_SETOTHERMODE_H gSetTextureFilter
G_TF_POINT = 0
G_TF_AVERAGE = 3
G_TF_BILERP = 2

-- G_SETOTHERMODE_H gSetTextureConvert
G_TC_CONV = 0
G_TC_FILTCONV = 5
G_TC_FILT = 6

-- G_SETOTHERMODE_H gSetCombineKey
G_CK_NONE = 0
G_CK_KEY = 1

-- G_SETOTHERMODE_H gSetColorDither
G_CD_MAGICSQ = 0
G_CD_BAYER = 1
G_CD_NOISE = 2

-- G_SETOTHERMODE_H gSetAlphaDither
G_AD_PATTERN = 0
G_AD_NOTPATTERN = 1
G_AD_NOISE = 2
G_AD_DISABLE = 3

-- G_SETOTHERMODE_L gSetAlphaCompare
G_AC_NONE = bit.lshift(0, G_MDSFT_ALPHACOMPARE)
G_AC_THRESHOLD = bit.lshift(1, G_MDSFT_ALPHACOMPARE)
G_AC_DITHER = bit.lshift(3, G_MDSFT_ALPHACOMPARE)

-- G_SETOTHERMODE_L gSetDepthSource
G_ZS_PIXEL = bit.lshift(0, G_MDSFT_ZSRCSEL)
G_ZS_PRIM = bit.lshift(1, G_MDSFT_ZSRCSEL)

-- G_SETOTHERMODE_L gSetRenderMode
AA_EN = 0x8
Z_CMP = 0x10
Z_UPD = 0x20
IM_RD = 0x40
CLR_ON_CVG = 0x80
CVG_DST_CLAMP = 0
CVG_DST_WRAP = 0x100
CVG_DST_FULL = 0x200
CVG_DST_SAVE = 0x300
ZMODE_OPA = 0
ZMODE_INTER = 0x400
ZMODE_XLU = 0x800
ZMODE_DEC = 0xc00
CVG_X_ALPHA = 0x1000
ALPHA_CVG_SEL = 0x2000
FORCE_BL = 0x4000
TEX_EDGE = 0x0000 -- used to be 0x8000

G_BL_CLR_IN = 0
G_BL_CLR_MEM = 1
G_BL_CLR_BL = 2
G_BL_CLR_FOG = 3
G_BL_1MA = 0
G_BL_A_MEM = 1
G_BL_A_IN = 0
G_BL_A_FOG = 1
G_BL_A_SHADE = 2
G_BL_1 = 2
G_BL_0 = 3

CC_0 = 0
CC_TEXEL0 = 1
CC_TEXEL1 = 2
CC_PRIM = 3
CC_SHADE = 4
CC_ENV = 5
CC_TEXEL0A = 6
CC_LOD = 7

SHADER_0 = 0
SHADER_INPUT_1 = 1
SHADER_INPUT_2 = 2
SHADER_INPUT_3 = 3
SHADER_INPUT_4 = 4
SHADER_TEXEL0 = 5
SHADER_TEXEL0A = 6
SHADER_TEXEL1 = 7

SHADER_OPT_ALPHA = bit.lshift(1, 24)
SHADER_OPT_FOG = bit.lshift(1, 25)
SHADER_OPT_TEXTURE_EDGE = bit.lshift(1, 26)

-- G_SETCOMBINE: color combine modes
-- Color combiner constants:
G_CCMUX_COMBINED = 0
G_CCMUX_TEXEL0 = 1
G_CCMUX_TEXEL1 = 2
G_CCMUX_PRIMITIVE = 3
G_CCMUX_SHADE = 4
G_CCMUX_ENVIRONMENT = 5
G_CCMUX_CENTER = 6
G_CCMUX_SCALE = 6
G_CCMUX_COMBINED_ALPHA = 7
G_CCMUX_TEXEL0_ALPHA = 8
G_CCMUX_TEXEL1_ALPHA = 9
G_CCMUX_PRIMITIVE_ALPHA = 10
G_CCMUX_SHADE_ALPHA = 11
G_CCMUX_ENV_ALPHA = 12
G_CCMUX_LOD_FRACTION = 13
G_CCMUX_PRIM_LOD_FRAC = 14
G_CCMUX_NOISE = 7
G_CCMUX_K4 = 7
G_CCMUX_K5 = 15
G_CCMUX_1 = 6
G_CCMUX_0 = 31

-- Alpha combiner constants:
G_ACMUX_COMBINED = 0
G_ACMUX_TEXEL0 = 1
G_ACMUX_TEXEL1 = 2
G_ACMUX_PRIMITIVE = 3
G_ACMUX_SHADE = 4
G_ACMUX_ENVIRONMENT = 5
G_ACMUX_LOD_FRACTION = 0
G_ACMUX_PRIM_LOD_FRAC = 6
G_ACMUX_1 = 6
G_ACMUX_0 = 7

-- G_SETIMG fmt: set image formats
G_IM_FMT_RGBA = 0
G_IM_FMT_YUV = 1
G_IM_FMT_CI = 2
G_IM_FMT_IA = 3
G_IM_FMT_I = 4

-- G_SETIMG siz: set image pixel size
G_IM_SIZ_4b = 0
G_IM_SIZ_8b = 1
G_IM_SIZ_16b = 2
G_IM_SIZ_32b = 3
G_IM_SIZ_DD = 5

G_IM_SIZ_INCR_TABLE = {
	1,
	0
}
G_IM_SIZ_SHIFT_TABLE = {
	1,
	0
}

G_IM_SIZ_LOAD_BLOCK_TABLE = {
	G_IM_SIZ_16b,
	G_IM_SIZ_16b
}
G_IM_SIZ_BYTES_TABLE = {
	G_IM_SIZ_8b,
	G_IM_SIZ_16b
}

G_IM_SIZ_LINE_BYTES_TABLE = {
	G_IM_SIZ_8b,
	G_IM_SIZ_16b
}

G_TX_LOADTILE = 7
G_TX_RENDERTILE = 0

G_TX_NOMIRROR = 0
G_TX_WRAP = 0
G_TX_MIRROR = 0x1
G_TX_CLAMP = 0x2
G_TX_NOMASK = 0
G_TX_NOLOD = 0

-- Render Modes
G_RM_OPA_SURF_SURF2 = 0xf0a4000
G_RM_AA_OPA_SURF_SURF2 = 0x552048
G_RM_AA_XLU_SURF_SURF2 = 0x5041c8

G_RM_ZB_OPA_SURF_SURF2 = 0x552230
G_RM_AA_ZB_TEX_EDGE_NOOP2 = 0x443078
G_RM_AA_ZB_OPA_INTER_NOOP2 = 0x442478
G_RM_AA_ZB_XLU_DECAL_DECAL2 = 0x504dd8
G_RM_AA_ZB_XLU_SURF_SURF2 = 0x5049d8
G_RM_AA_ZB_XLU_SURF_NOOP2 = 0x4049d8
G_RM_AA_ZB_OPA_SURF_NOOP2 = 0x442078
G_RM_AA_ZB_OPA_SURF_SURF2 = 0x552078
G_RM_AA_ZB_OPA_DECAL_DECAL2 = 0x552d58
G_RM_AA_ZB_OPA_DECAL_NOOP2 = 0x442d58
G_RM_AA_ZB_XLU_INTER_INTER2 = 0x5045d8
G_RM_FOG_SHADE_A_AA_ZB_OPA_SURF2 = 0xc8112078
G_RM_FOG_SHADE_A_AA_ZB_TEX_EDGE2 = 0xc8113078
G_RM_FOG_SHADE_A_AA_ZB_OPA_DECAL2 = 0xc8112d58
G_RM_FOG_SHADE_A_AA_ZB_XLU_SURF2 = 0xc81049d8

-- G_MOVEWORD types
G_MW_MATRIX = 0x00 -- NOTE: also used by movemem
G_MW_NUMLIGHT = 0x02
G_MW_CLIP = 0x04
G_MW_SEGMENT = 0x06
G_MW_FOG = 0x08
G_MW_LIGHTCOL = 0x0a
G_MW_POINTS = 0x0c
G_MW_PERSPNORM = 0x0e

-- G_MOVEMEM types
G_MV_VIEWPORT = 1
G_MV_L = 2

-- G_MTX parameter flags
G_MTX_MODELVIEW = 0 -- matrix types
G_MTX_PROJECTION = 1
G_MTX_MUL = 0 -- concat or load
G_MTX_LOAD = 2
G_MTX_NOPUSH = 0 -- push or not
G_MTX_PUSH = 4

G_CC_PRIMITIVE = {
	alpha = {7, 7, 7, 3},
	rgb = {15, 15, 31, 3}
}

G_CC_MODULATERGB = {
	alpha = {7, 7, 7, 4},
	rgb = {1, 15, 4, 7}
}

G_CC_MODULATEI = {
	alpha = {7, 7, 7, 4},
	rgb = {1, 15, 4, 7}
}

G_CC_MODULATERGBFADE = { 
	alpha = {7, 7, 7, 5},
	rgb = {1, 15, 4, 7}
}

G_CC_MODULATERGBA = {
	alpha = {1, 7, 4, 7},
	rgb = {1, 15, 4, 7}
}

G_CC_MODULATEIA = {
	alpha = {1, 7, 4, 7},
	rgb = {1, 15, 4, 7}
}

G_CC_MODULATEIFADEA = {
	alpha = {1, 7, 5, 7},
	rgb = {1, 15, 4, 7}
}

G_CC_MODULATEIDECALA = {
	alpha = {7, 7, 7, 1},
	rgb = {1, 15, 4, 7}
}

G_CC_MODULATERGBA_PRIM = {
	alpha = {1, 7, 3, 7},
	rgb = {1, 15, 3, 7}
}

G_CC_SHADE = {
	alpha = {7, 7, 7, 4},
	rgb = {15, 15, 31, 4}
}

G_CC_SHADEFADEA = {
	alpha = {7, 7, 7, 5},
	rgb = {15, 15, 31, 4}
}

G_CC_BLENDRGBFADEA = {
	alpha = {7, 7, 7, 5},
	rgb = {1, 4, 8, 4}
}

G_CC_DECALFADE = {
	alpha = {7, 7, 7, 5},
	rgb = {15, 15, 31, 1}
}

G_CC_DECALFADEA = {
	alpha = {1, 7, 5, 7},
	rgb = {15, 15, 31, 1}
}

G_CC_DECALRGBA = {
	alpha = {7, 7, 7, 1},
	rgb = {15, 15, 31, 1}
}

G_CC_DECALRGB = {
	alpha = {7, 7, 7, 4},
	rgb = {15, 15, 31, 1}
}

G_CC_HILITERGBA = {
	alpha = {3, 4, 1, 4},
	rgb = {3, 4, 1, 4}
}

function gdSPDefLights1(ar, ag, ab, r1, g1, b1, x1, y1, z1)
	return {
		a = {col = {ar, ag, ab}},
		l = {
			{
				col = {r1, g1, b1},
				dir = {x1, y1, z1}
			}
		}
	}
end

function gSPLight(displaylist, lightData, index)
	table.insert(displaylist, {
		words = {
			w0 = G_MOVEMEM,
			w1 = {type = G_MV_L, data = lightData, index = index - 1}
			-- the `index - 1` I don't like and isn't needed, but it makes matching with decomp code easier
		}
	})
end

function gSPNumLights(displaylist, num)
	table.insert(displaylist, {
		words = {
			w0 = G_MOVEWORD,
			w1 = {type = G_MW_NUMLIGHT, data = num + 1} -- includes 1 ambient light
		}
	})
end

function gSPFogFactor(displaylist, f_mul, f_offset)
	table.insert(displaylist, {
		words = {
			w0 = G_MOVEWORD,
			w1 = {
				type = G_MW_FOG,
				data = {
					mul = f_mul,
					offset = f_offset
				}
			}
		}
	})
end

function gSPFogPosition(displaylist, min, max)
	table.insert(displaylist, {
		words = {
			w0 = G_MOVEWORD,
			w1 = {
				type = G_MW_FOG,
				data = {
					mul = (128000 / ((max) - (min))),
					offset = ((500 - (min)) * 256 / ((max) - (min)))
				}
			}
		}
	})
end

function gDPSetFogColor(displaylist, r, g, b, a)
	table.insert(displaylist, {
		words = {
			w0 = G_SETFOGCOLOR,
			w1 = {r, g, b, a}
		}
	})
end

function gDPSetEnvColor(displaylist, r, g, b, a)
	table.insert(displaylist, {
		words = {
			w0 = G_SETENVCOLOR,
			w1 = {r, g, b, a}
		}
	})
end

function gDPSetFillColor(displaylist, color)
	table.insert(displaylist, {
		words = {
			w0 = G_SETFILLCOLOR,
			w1 = {color}
		}
	})
end

function gDPFillRectangle(displaylist, ulx, uly, lrx, lry)
	table.insert(displaylist, {
		words = {
			w0 = G_FILLRECT,
			w1 = {ulx, uly, lrx, lry}
		}
	})
end

function gSPTextureRectangle(displaylist, ulx, uly, lrx, lry, tile, uls, ult, dsdx, dtdy)
	table.insert(displaylist, {
		words = {
			w0 = G_TEXRECT,
			w1 = {ulx, uly, lrx, lry, tile, uls, ult, dsdx, dtdy}
		}
	})
end

function gSPTextureRectangleFlip(displaylist, ulx, uly, lrx, lry, tile, uls, ult, dsdx, dtdy)
	table.insert(displaylist, {
		words = {
			w0 = G_FILLRECTFLIP,
			w1 = {ulx, uly, lrx, lry, tile, uls, ult, dsdx, dtdy}
		}
	})
end

function gSPTexture(displaylist, s, t, level, tile, on)
	table.insert(displaylist, {
		words = {
			w0 = G_TEXTURE,
			w1 = {s, t}
		}
	})
end

function gDPSetCombineMode(displaylist, mode)
	table.insert(displaylist, {
		words = {
			w0 = G_SETCOMBINE,
			w1 = {mode}
		}
	})
end

function gDPSetTileSize(displaylist, t, uls, ult, lrs, lrt)
	table.insert(displaylist, {
		words = {
			w0 = G_SETTILESIZE,
			w1 = {t, uls, ult, lrs, lrt}
		}
	})
end

function gDPSetHilite1Tile(displaylist, tile, hilite, width, height)
	gDPSetTileSize(displaylist, tile,
		bit.band(hilite.x1, 0xfff),
		bit.band(hilite.y1, 0xfff),
		bit.band((((width - 1) * 4) + hilite.x1), 0xfff),
		bit.band((((height - 1) * 4) + hilite.y1), 0xfff)
	)
end

function gSPMatrix(displaylist, matrix, parameters)
	table.insert(displaylist, {
		words = {
			w0 = G_MTX,
			w1 = {matrix, parameters}
		}
	})
end

function gDPSetRenderMode(displaylist, mode)
	table.insert(displaylist, {
		words = {
			w0 = G_SETOTHERMODE_L,
			w1 = {mode}
		}
	})
end
function gDPSetTextureFilter(displaylist, newmode)
	table.insert(displaylist, {
		words = {
			w0 = G_SETOTHERMODE_H,
			w1 = {category = G_MDSFT_TEXTFILT, newmode}
		}
	})
end

function gDPSetCycleType(displaylist, newmode)
	table.insert(displaylist, {
		words = {
			w0 = G_SETOTHERMODE_H,
			w1 = {category = G_MDSFT_CYCLETYPE, newmode}
		}
	})
end

function gSPVertex(displaylist, vertices, num_vertices, dest_index)
	table.insert(displaylist, {
		words = {
			w0 = G_VTX,
			w1 = {vertices, dest_index}
		}
	})
end

function gSP1Triangle(displaylist, v0, v1, v2, flag)
	table.insert(displaylist, {
		words = {
			w0 = G_TRI1,
			w1 = {v0, v1, v2, flag}
		}
	})
end

function gSPViewport(displaylist, viewportData)
	table.insert(displaylist, {
		words = {
			w0 = G_MOVEMEM,
			w1 = {type = G_MV_VIEWPORT, data = viewportData}
		}
	})
end

function gDPSetPrimColor(displaylist, m, l, r, g, b, a)
	table.insert(displaylist, {
		words = {
			w0 = G_SETPRIMCOLOR,
			w1 = {m, l, r, g, b, a}
		}
	})
end


function gSPSetGeometryMode(displaylist, mode)
	table.insert(displaylist, {
		words = {
			w0 = G_SETGEOMETRYMODE,
			w1 = {mode}
		}
	})
end

function gSPClearGeometryMode(displaylist, mode)
	table.insert(displaylist, {
		words = {
			w0 = G_CLEARGEOMETRYMODE,
			w1 = {mode}
		}
	})
end

function gSPEndDisplayList(displaylist)
	table.insert(displaylist, {
		words = {
			w0 = G_ENDDL
		}
	})
end

function gSPBranchList(displaylist, childDisplayList)
	table.insert(displaylist, {
		words = {
			w0 = G_DL,
			w1 = {childDisplayList, branch = G_DL_NOPUSH}
		}
	})
end

function gSPDisplayList(displaylist, childDisplayList)
	table.insert(displaylist, {
		words = {
			w0 = G_DL,
			w1 = {childDisplayList, branch = G_DL_PUSH}
		}
	})
end

function gDPSetTextureImage(displaylist, format, size, width, imageData)
	table.insert(displaylist, {
		 words = {
			w0 = G_SETTIMG,
			w1 = {format, size, width, imageData}
		}
	})
end

function gDPLoadBlock(displaylist, tile, uls, ult, lrs) ///dxt skipped
	table.insert(displaylist, {
		words = {
			w0 = G_LOADBLOCK,
			w1 = {tile, uls, ult, lrs}
		}
	})
end


function gDPLoadBlockTexture(displaylist, width, height, format, image)
	table.insert(displaylist,
		gsDPSetTextureImage(format, G_IM_SIZ_16b, 1, image),
		gsDPSetTile(format, G_IM_SIZ_16b, 0, 0, G_TX_LOADTILE, 0, G_TX_NOMIRROR, G_TX_NOMASK, G_TX_NOLOD, G_TX_NOMIRROR, G_TX_NOMASK, G_TX_NOLOD),
		gsDPLoadBlock(G_TX_LOADTILE, 0, 0, (width * height) - 1)
	)
end

function gDPLoadTextureBlock(displaylist, timg, fmt, siz, width, height, pal, cms, cmt, masks, maskt, shifts, shiftt)
	table.insert(displaylist,
		gsDPSetTextureImage(fmt, G_IM_SIZ_LOAD_BLOCK_TABLE[siz], 1, timg),
		gsDPSetTile(fmt, G_IM_SIZ_LOAD_BLOCK_TABLE[siz], 0, 0, G_TX_LOADTILE, 0, cmt, maskt, shiftt, cms, masks, shifts),
		gsDPLoadBlock(G_TX_LOADTILE, 0, 0, bit.rshift(((width) * (height) + G_IM_SIZ_INCR_TABLE[siz]), G_IM_SIZ_SHIFT_TABLE[siz]) - 1),
		gsDPSetTile(fmt, siz,
			bit.rshift((((width) * G_IM_SIZ_LINE_BYTES_TABLE[siz]) + 7), 3),
			0, G_TX_RENDERTILE, pal, cmt, maskt, shiftt, cms, masks, shifts),
		gsDPSetTileSize(G_TX_RENDERTILE, 0, 0, bit.lshift(((width) - 1), G_TEXTURE_IMAGE_FRAC), bit.lshift(((height) - 1), G_TEXTURE_IMAGE_FRAC))
	)
end

function gsSPDisplayList(childDisplayList)
	return {
		words = {
			w0 = G_DL,
			w1 = {childDisplayList, branch = G_DL_PUSH}
		}
	}
end

function gsSPBranchList(childDisplayList)
	return {
		words = {
			w0 = G_DL,
			w1 = {childDisplayList, branch = G_DL_NOPUSH}
		}
	}
end

function gsSPEndDisplayList()
	return {
		words = {
			w0 = G_ENDDL
		}
	}
end

function gsDPSetRenderMode(mode)
	return {
		words = {
			w0 = G_SETOTHERMODE_L,
			w1 = {mode}
		}
	}
end

function gsDPSetTextureFilter(newmode)
	return {
		words = {
			w0 = G_SETOTHERMODE_H,
			w1 = {category = G_MDSFT_TEXTFILT, newmode}
		}
	}
end

function gsDPSetCycleType(newmode)
	return {
		words = {
			w0 = G_SETOTHERMODE_H,
			w1 = {category = G_MDSFT_CYCLETYPE, newmode}
		}
	}
end

function gsSPLight(lightData, index)
	return {
		words = {
			w0 = G_MOVEMEM,
			w1 = {type = G_MV_L, data = lightData, index = index - 1}
			-- the `index - 1` I don't like and isn't needed, but it makes matching with decomp code easier
		}
	}
end

function gsSPNumLights(num)
	return {
		words = {
			w0 = G_MOVEWORD,
			w1 = {type = G_MW_NUMLIGHT, data = num + 1} -- includes 1 ambient light
		}
	}
end

function gsSPFogFactor(f_mul, f_offset)
	return {
		words = {
			w0 = G_MOVEWORD,
			w1 = {
				type = G_MW_FOG,
				data = {
					mul = f_mul,
					offset = f_offset
				}
			}
		}
	}
end

function gsSPFogPosition(min, max)
	return {
		words = {
			w0 = G_MOVEWORD,
			w1 = {
				type = G_MW_FOG,
				data = {
					mul = (128000 / ((max) - (min))),
					offset = ((500 - (min)) * 256 / ((max) - (min)))
				}
			}
		}
	}
end

function gsSPClearGeometryMode(mode)
	return {
		words = {
			w0 = G_CLEARGEOMETRYMODE,
			w1 = {mode}
		}
	}
end

function gsSPSetGeometryMode(mode)
	return {
		words = {
			w0 = G_SETGEOMETRYMODE,
			w1 = {mode}
		}
	}
end

function gsDPSetCombineMode(mode)
	return {
		words = {
			w0 = G_SETCOMBINE,
			w1 = {mode}
		}
	}
end

function gsSPMatrix(matrix, parameters)
	return {
		words = {
			w0 = G_MTX,
			w1 = {matrix, parameters}
		}
	}
end

function gsDPSetFogColor(r, g, b, a)
	return {
		words = {
			w0 = G_SETFOGCOLOR,
			w1 = {r, g, b, a}
		}
	}
end

function gsDPSetEnvColor(r, g, b, a)
	return {
		words = {
			w0 = G_SETENVCOLOR,
			w1 = {r, g, b, a}
		}
	}
end

function gsDPSetPrimColor(m, l, r, g, b, a)
	return {
		words = {
			w0 = G_SETPRIMCOLOR,
			w1 = {m, l, r, g, b, a}
		}
	}
end

function gsDPSetTile(fmt, siz, line, tmem, tile, palette, cmt, maskt, shiftt, cms, masks, shifts)
	return {
		words = {
			w0 = G_SETTILE,
			w1 = {fmt, siz, line, tmem, tile, palette, cmt, cms}
		}
	}
end

function gsSPTexture(s, t, level, tile, on)
	return {
		words = {
			w0 = G_TEXTURE,
			w1 = {s, t}
		}
	}
end

function gsDPSetTileSize(t, uls, ult, lrs, lrt)
	return {
		words = {
			w0 = G_SETTILESIZE,
			w1 = {t, uls, ult, lrs, lrt}
		}
	}
end

function gsDPSetTextureImage(format, size, width, imageData)
	return {
		words = {
			w0 = G_SETTIMG,
			w1 = {format, size, width, imageData}
		}
	}
end

function gsDPLoadBlock(tile, uls, ult, lrs) -- dxt skipped
	return {
		words = {
			w0 = G_LOADBLOCK,
			w1 = {tile, uls, ult, lrs}
		}
	}
end

function gsSPVertex(vertices, num_vertices, dest_index)
	return {
		words = {
			w0 = G_VTX,
			w1 = {vertices, dest_index}
		}
	}
end

function gsSP1Triangle(v0, v1, v2, flag)
	return {
		words = {
			w0 = G_TRI1,
			w1 = {v0, v1, v2, flag}
		}
	}
end

function gsSP2Triangles(v00, v01, v02, flag0, v10, v11, v12, flag1)
	return {{
		words = {
			w0 = G_TRI1,
			w1 = {v0 = v00, v1 = v01, v2 = v02, flag = flag0}
		}
	}, {
		words = {
			w0 = G_TRI1,
			w1 = {v0 = v10, v1 = v11, v2 = v12, flag = flag1}
		}
	}}
end

function gsDPLoadTextureBlock(timg, fmt, siz, width, height, pal, cms, cmt, masks, maskt, shifts, shiftt)
	return {
		gsDPSetTextureImage(fmt, G_IM_SIZ_LOAD_BLOCK_TABLE[siz], 1, timg),
		gsDPSetTile(fmt, G_IM_SIZ_LOAD_BLOCK_TABLE[siz], 0, 0, G_TX_LOADTILE, 0, cmt, maskt, shiftt, cms, masks, shifts),
		gsDPLoadBlock(G_TX_LOADTILE, 0, 0, bit.rshift(((width) * (height) + G_IM_SIZ_INCR_TABLE[siz]), G_IM_SIZ_SHIFT_TABLE[siz]) - 1),
		gsDPSetTile(fmt, siz,
			bit.rshift((((width) * G_IM_SIZ_LINE_BYTES_TABLE[siz]) + 7), 3),
			0, G_TX_RENDERTILE, pal, cmt, maskt, shiftt, cms, masks, shifts),
		gsDPSetTileSize(G_TX_RENDERTILE, 0, 0, bit.lshift(((width) - 1), G_TEXTURE_IMAGE_FRAC), bit.lshift(((height) - 1), G_TEXTURE_IMAGE_FRAC))
	}
end

-----END SM64JS DERIVED CODE-----

-- vertex (set up for use with colors)
local function Vtx_t()
	-- GBI_FLOATS
	return {
		ob = Vector(0, 0, 0), -- x, y, z
		flag = 0,
		tc = {0, 0}, -- texture coord
		cn = Color(0, 0, 0, 0), -- color & alpha
	}
end

-- Vertex (set up for use with normals)
local function Vtx_tn()
	-- GBI_FLOATS
	return {
		ob = Vector(0, 0, 0), -- x, y, z
		flag = 0,
		tc = {0, 0}, -- texture coord
		n = {0, 0, 0},
		a = 0,
	}
end

function Vtx(n)
	local t = {}
	for i=1, n do
		t[i] = {
			v = Vtx_t(),
			n = Vtx_tn(),
		}
	end
	return t
end
