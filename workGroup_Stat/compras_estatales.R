############################
#### COMPRAS ESTATALES #####
############################

library(tidyverse)
library(lubridate)
library(stringr)
library(rvest)
library(magrittr)

#### PARSERS METADATA ####

## Estados de compras ##
url_estados_compras <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteEstadosCompra.do"
estados_compra <- read_lines(url_estados_compras, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<estados-compra>)", replacement = "") %>% 
   str_replace(pattern = "(</estados-compra>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<estado-compra ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3")) %>% 
   separate(x, sep = "@",
            into = c("id_estado_compra", "descripcion")) %>% 
   mutate(id_estado_compra = as.numeric(str_replace_all(string = id_estado_compra, pattern = "[^0-9]", replacement = "")),
          descripcion = str_to_title(str_replace_all(string = descripcion, pattern = "(^descripcion=\")|(\"\\s/>)$", replacement = ""))) %>% 
   filter(!is.na(descripcion))
write_rds(estados_compra, path = "Data/rds/meta_estado_compra.rds")

## Estados proveedor ##
url_estados_proveedor <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteEstadosProveedor.do"
estados_proveedor <- read_lines(url_estados_proveedor, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<estados-proveedor>)", replacement = "") %>% 
   str_replace(pattern = "(</estados-proveedor>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<estado-proveedor ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3")) %>% 
   separate(x, sep = "@",
            into = c("estado", "desc_estado", "val_adjs", "val_amps")) %>% 
   mutate(estado = str_to_title(str_replace_all(string = estado, pattern = "^(estado=\")|(\")$", replacement = "")),
          desc_estado = str_replace_all(string = desc_estado, pattern = "(^desc-estado=\")|(\")$", replacement = ""),
          val_adjs = str_replace(string = val_adjs, pattern = "^.*(S|N).*$", replacement = "\\1"),
          val_amps = str_replace(string = val_amps, pattern = "^.*(S|N).*$", replacement = "\\1")) %>% 
   filter(!is.na(desc_estado))
write_rds(estados_proveedor, path = "Data/rds/meta_estado_proveedor.rds")

## Incisos ##
url_incisos <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteIncisos.do"
incisos <- read_lines(url_incisos, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<incisos>)", replacement = "") %>% 
   str_replace(pattern = "(</incisos>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<inciso ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3")) %>% 
   separate(x, sep = "@",
            into = c("inciso", "nom_inciso")) %>% 
   mutate(inciso = as.numeric(str_replace_all(string = inciso, pattern = "[^0-9]", replacement = "")),
          nom_inciso = str_replace_all(string = nom_inciso, pattern = "^(nom-inciso=\")|(\"\\s/>)$", replacement = "")) %>% 
   filter(!is.na(nom_inciso))
write_rds(incisos, path = "Data/rds/meta_id_inciso.rds")

## Monedas ##
url_monedas <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteMonedas.do"
monedas <- read_lines(url_monedas, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<monedas>)", replacement = "") %>% 
   str_replace(pattern = "(</monedas>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<moneda ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3")) %>% 
   separate(x, sep = "@",
            into = c("id_moneda", "desc_moneda", "sigla_moneda", "id_moneda_arbitraje")) %>% 
   mutate(id_moneda = as.numeric(str_replace_all(string = id_moneda, pattern = "[^0-9]", replacement = "")),
          desc_moneda = str_to_title(str_replace_all(string = desc_moneda, pattern = "(^desc-moneda=\")|(\")$", replacement = "")),
          sigla_moneda = str_replace_all(string = sigla_moneda, pattern = "(^sigla-moneda=\")|(\")", replacement = ""),
          id_moneda_arbitraje = as.numeric(str_replace_all(string = id_moneda_arbitraje, pattern = "[^0-9]", replacement = ""))) %>% 
   filter(!is.na(id_moneda))
write_rds(monedas, path = "Data/rds/meta_id_moneda.rds")

## Objetos gasto ##
url_objetos_gasto <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteObjetosGasto.do"
objetos_gastos <- read_lines(url_objetos_gasto, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<objetos-gastos>)", replacement = "") %>% 
   str_replace(pattern = "(</objetos-gastos>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<objeto-gasto ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3")) %>% 
   separate(x, sep = "@",
            into = c("odg", "descripcion")) %>% 
   mutate(odg = as.numeric(str_replace_all(string = odg, pattern = "[^0-9]", replacement = "")),
          descripcion = str_to_title(str_replace_all(string = descripcion, pattern = "^(descripcion=\")|(\"\\s/>)$", replacement = ""))) %>% 
   filter(!is.na(odg))
write_rds(objetos_gastos, path = "Data/rds/meta_objetos_gastos.rds")

## Porcentaje suprograma PCPD ##
url_pcpd <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reportePorcentajesSubprogramasPCPD.do"
porcentaje_subprograma_pcpd <- read_lines(url_pcpd, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<porcentajes-subprograma-pcpd>)", replacement = "") %>% 
   str_replace(pattern = "(</porcentajes-subprograma-pcpd>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<porcentaje-subprograma-pcpd ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3")) %>% 
   separate(x, sep = "@",
            into = c("codigo_subprograma", "fecha_vigencia", "porcentaje")) %>% 
   mutate(codigo_subprograma = as.numeric(str_replace_all(string = codigo_subprograma, pattern = "[^0-9]", replacement = "")),
          fecha_vigencia = lubridate::dmy(str_replace_all(string = fecha_vigencia, pattern = "^(fecha-vigencia=\")|(\")", replacement = "")),
          porcentaje = as.numeric(str_replace_all(string = porcentaje, pattern = "[^0-9]", replacement = ""))) %>% 
   filter(!is.na(codigo_subprograma))
write_rds(porcentaje_subprograma_pcpd, path = "Data/rds/meta_porcentaje_subprograma_pcpd.rds")

## Suprogramas PCPD ##
url_subprogramas_pcpd <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteSubprogramasPCPD.do"
subprogramas_pcpd <- read_lines(url_subprogramas_pcpd, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<subprogramas-pcpd>)", replacement = "") %>% 
   str_replace(pattern = "(</subprogramas-pcpd>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<subprograma-pcpd ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3")) %>% 
   separate(x, sep = "@",
            into = c("codigo", "descripcion", "fecha_desde", "fecha_hasta")) %>% 
   mutate(codigo = as.numeric(str_replace_all(string = codigo, pattern = "[^0-9]", replacement = "")),
          descripcion = str_replace_all(string = descripcion, pattern = "^(descripcion=\")|(\")", replacement = ""),
          fecha_desde = lubridate::dmy(str_replace_all(string = fecha_desde, pattern = "^(fecha-desde=\")|(\")", replacement = "")),
          fecha_hasta = str_replace_all(string = fecha_hasta, pattern = "^(fecha-hasta=\")|(\"\\s/>)", replacement = "")) %>% 
   filter(!is.na(codigo))
write_rds(subprogramas_pcpd, path = "Data/rds/meta_subprogramas_pcpd.rds")

## Subtipos compra (falta codificar correctamente condicion precios oferta - revisar en caso de usar -) ##
url_subtipos_compra <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteSubTiposCompra.do"
subtipos_compras <- read_lines(url_subtipos_compra, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<subtipos-compra>)", replacement = "") %>% 
   str_replace(pattern = "(</subtipos-compra>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<subtipo-compra ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3"),
          x = if_else(str_detect(string = x, pattern = "pub-llamado") == FALSE,
                      str_replace(string = x, pattern = "@cond", replacement = "@@cond"), x),
          x = if_else(str_detect(string = x, pattern = "pub-adj") == FALSE,
                      str_replace(string = x, pattern = "@cant-adj", replacement = "@@cant-adj"), x),
          x = if_else(str_detect(string = x, pattern = "prov-rupe") == FALSE,
                      str_replace(string = x, pattern = "@pub-adj", replacement = "@@pub-adj"), x)) %>% 
   separate(x, sep = "@",
            into = c("id", "id_tipocompra", "resumen", "pub_llamado", "cond_precios_ofertas", "fecha_baja", "prov_rupe", 
                     "pub_adj", "cant_adj")) %>% 
   mutate(id = str_replace_all(string = id, pattern = "^(id=\")|(\")$", replacement = ""),
          id_tipocompra = str_replace_all(string = id_tipocompra, pattern = "^(id-tipocompra=\")|(\")", replacement = ""),
          resumen = str_replace_all(string = resumen, pattern = "^(resumen=\")|(\")", replacement = ""),
          pub_llamado = str_replace_all(string = pub_llamado, pattern = "^(pub-llamado=\")|(\")$", replacement = ""),
          cond_precios_ofertas = str_replace_all(string = cond_precios_ofertas, pattern = "^(cond-precios-ofertas=\")|(\")$", replacement = ""),
          cond_precios_ofertas = str_replace_all(string = cond_precios_ofertas, pattern = "\\&gt;", replacement = ">"),
          fecha_baja = lubridate::dmy(str_replace_all(string = fecha_baja, pattern = "^(fecha-baja=\")|(\")", replacement = "")),
          prov_rupe = str_replace_all(string = prov_rupe, pattern = "^(prov-rupe=\")|(\")$", replacement = ""),
          pub_adj = str_replace_all(string = pub_adj, pattern = "^(pub-adj=\")|(\")$", replacement = ""),
          cant_adj = str_replace_all(string = cant_adj, pattern = "^(cant-adj=\")|(\"\\s/>)$", replacement = "")) %>% 
   filter(!is.na(id_tipocompra))
write_rds(subtipos_compras, path = "Data/rds/meta_subtipos_compra.rds")

## Tipos de ajustes de adjuudiicacion ##
url_tipos_ajustes_adj <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteTiposAjusteAdj.do"
tipos_ajustes_adj <- read_lines(url_tipos_ajustes_adj, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<tipos-ajuste-adj>)", replacement = "") %>% 
   str_replace(pattern = "(</tipos-ajuste-adj>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<tipo-ajuste-adj ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3"),
          x = if_else(str_detect(string = x, pattern = "nuevo-item-ofe") == FALSE,
                      str_replace(string = x, pattern = "@modif-item-adj", replacement = "@@modif-item-adj"), x)) %>% 
   separate(x, sep = "@",
            into = c("id", "descripcion", "reiteracion", "resolucion", "pub_llamado", "nuevo_item_ofe", "modif_item_adj", 
                     "nuevo_item_adj")) %>% 
   mutate(id = as.numeric(str_replace_all(string = id, pattern = "[^0-9]", replacement = "")),
          descripcion = str_replace_all(string = descripcion, pattern = "^(descripcion=\")|(\")", replacement = ""),
          reiteracion = str_replace_all(string = reiteracion, pattern = "^(reiteracion=\")|(\")", replacement = ""),
          resolucion = str_replace_all(string = resolucion, pattern = "^(resolucion=\")|(\")$", replacement = ""),
          pub_llamado = str_replace_all(string = pub_llamado, pattern = "^(pub-llamado=\")|(\")$", replacement = ""),
          nuevo_item_ofe = str_replace_all(string = nuevo_item_ofe, pattern = "^(nuevo-item-ofe=\")|(\")$", replacement = ""),
          modif_item_adj = str_replace_all(string = modif_item_adj, pattern = "^(modif-item-adj=\")|(\")$", replacement = ""),
          nuevo_item_adj = str_replace_all(string = nuevo_item_adj, pattern = "^(nuevo-item-adj=\")|(\"\\s/>)$", replacement = "")) %>% 
   filter(!is.na(id))
write_rds(tipos_ajustes_adj, path = "Data/rds/meta_tipos_ajustes_adj.rds")

## Tipos de compra ##
url_tipos_compra <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteTiposCompra.do"
tipos_compra <- read_lines(url_tipos_compra, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<tipos-compra>)", replacement = "") %>% 
   str_replace(pattern = "(</tipos-compra>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<tipo-compra ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3"),
          x = if_else(str_detect(string = x, pattern = "acto-apertura") == FALSE,
                      str_replace(string = x, pattern = "@plazo-min-oferta", replacement = "@@plazo-min-oferta"), x),
          x = if_else(str_detect(string = x, pattern = "plazo-min-oferta") == FALSE,
                      str_replace(string = x, pattern = "@resolucion-obligatoria", replacement = "@@resolucion-obligatoria"), x),
          x = if_else(str_detect(string = x, pattern = "solics-llamado") == FALSE,
                      str_replace(string = x, pattern = "@ampliaciones", replacement = "@@ampliaciones"), x),
          x = if_else(str_detect(string = x, pattern = "tope-legal") == FALSE,
                      str_replace(string = x, pattern = "@pcpd", replacement = "@@pcpd"), x)) %>% 
   separate(x, sep = "@",
            into = c("id", "descripcion", "oferta_economica", "acto_apertura", "plazo_min_oferta", "resolucion_obligatoria", 
                     "solics_llamado",  "ampliaciones", "tope_legal", "pcpd")) %>% 
   mutate(id = str_replace_all(string = id, pattern = "^(id=\")|(\")", replacement = ""),
          descripcion = str_replace_all(string = descripcion, pattern = "^(descripcion=\")|(\")", replacement = ""),
          oferta_economica = str_replace_all(string = oferta_economica, pattern = "^(oferta-economica=\")|(\")", replacement = ""),
          acto_apertura = str_replace_all(string = acto_apertura, pattern = "^(acto-apertura=\")|(\")$", replacement = ""),
          plazo_min_oferta = as.numeric(str_replace_all(string = plazo_min_oferta, pattern = "^(plazo-min-oferta=\")|(\")$", replacement = "")),
          resolucion_obligatoria = str_replace_all(string = resolucion_obligatoria, pattern = "^(resolucion-obligatoria=\")|(\")$", replacement = ""),
          solics_llamado = str_replace_all(string = solics_llamado, pattern = "^(solics-llamado=\")|(\")$", replacement = ""),
          ampliaciones = str_replace_all(string = ampliaciones, pattern = "^(ampliaciones=\")|(\")$", replacement = ""),
          tope_legal = str_replace_all(string = tope_legal, pattern = "^(tope-legal=\")|(\")$", replacement = ""),
          pcpd = str_replace_all(string = pcpd, pattern = "^(pcpd=\")|(\"\\s/>)$", replacement = "")) %>% 
   filter(!is.na(descripcion))
write_rds(tipos_compra, path = "Data/rds/meta_id_tipocompra.rds")

## Tipo de documentos de proveedor ##
url_tipos_doc_proveedor <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteTiposDocumento.do"
tipos_doc_proveedor <- read_lines(url_tipos_doc_proveedor, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<tipos-doc>)", replacement = "") %>% 
   str_replace(pattern = "(</tipos-doc>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<tipo-doc ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3")) %>% 
   separate(x, sep = "@",
            into = c("tipo", "descripcion", "prov_rupe", "pcpd")) %>% 
   mutate(tipo = str_replace_all(string = tipo, pattern = "^(tipo=\")|(\")", replacement = ""),
          descripcion = str_replace_all(string = descripcion, pattern = "^(descripcion=\")|(\")", replacement = ""),
          prov_rupe = str_replace_all(string = prov_rupe, pattern = "^(prov-rupe=\")|(\")", replacement = ""),
          pcpd = str_replace_all(string = pcpd, pattern = "^(pcpd=\")|(\"\\s/>)$", replacement = "")) %>% 
   filter(!is.na(descripcion))
write_rds(tipos_doc_proveedor, path = "Data/rds/meta_tipo_doc_prov.rds")

## Tipos de resolucion ##
url_tipos_resolucion <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteTiposResolucion.do"
tipos_resolucion <- read_lines(url_tipos_resolucion, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<tipos-res>)", replacement = "") %>% 
   str_replace(pattern = "(</tipos-res>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<tipo-res ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3")) %>% 
   separate(x, sep = "@",
            into = c("id", "descripcion")) %>% 
   mutate(id = as.numeric(str_replace_all(string = id, pattern = "[^0-9]", replacement = "")),
          descripcion = str_replace_all(string = descripcion, pattern = "^(descripcion=\")|(\"\\s/>)", replacement = "")) %>% 
   filter(!is.na(id))
write_rds(tipos_resolucion, path = "Data/rds/meta_id_tipo_resol.rds")

## Tipos resolucion tipo adjudicacion adjustes ##
url_tipos_resolucion_tipoajusteadj <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteTiposResolucionTipoAjusteAdj.do"
tipos_resolucion_tipoajusteadj <- read_lines(url_tipos_resolucion_tipoajusteadj, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<tipos-resolucion-tipoajusteadj>)", replacement = "") %>% 
   str_replace(pattern = "(</tipos-resolucion-tipoajusteadj>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<tipo-resolucion-tipoajusteadj ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3")) %>% 
   separate(x, sep = "@",
            into = c("id_tipoajusteadj", "id_tiporesol")) %>% 
   mutate(id_tipoajusteadj = as.numeric(str_replace_all(string = id_tipoajusteadj, pattern = "[^0-9]", replacement = "")),
          id_tiporesol = as.numeric(str_replace_all(string = id_tiporesol, pattern = "[^0-9]", replacement = ""))) %>% 
   filter(!is.na(id_tipoajusteadj))
write_rds(tipos_resolucion_tipoajusteadj, path = "Data/rds/meta_tipos_resolucion_tipoajusteadj.rds")

## Tipos resolucion tipo compra ##
url_tipos_resolucion_tipocompra <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteTiposResolucionCompra.do"
tipos_resolucion_tipocompra <- read_lines(url_tipos_resolucion_tipoajusteadj, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<tipos-resolucion-compra>)", replacement = "") %>% 
   str_replace(pattern = "(</tipos-resolucion-compra>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<tipo-resolucion-compra ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3")) %>% 
   separate(x, sep = "@",
            into = c("id_tipo_resolucion", "id_tipo_compra")) %>% 
   mutate(id_tipo_resolucion = as.numeric(str_replace_all(string = id_tipo_resolucion, pattern = "[^0-9]", replacement = "")),
          id_tipo_compra = as.numeric(str_replace_all(string = id_tipo_compra, pattern = "[^0-9]", replacement = ""))) %>% 
   filter(!is.na(id_tipo_resolucion))
write_rds(tipos_resolucion_tipocompra, path = "Data/rds/meta_tipos_resolucion_tipocompra.rds")

## Topes legales ##
url_topes_legales <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteTopesLegales.do"
topes_legales <- read_lines(url_topes_legales, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<topes-legales>)", replacement = "") %>% 
   str_replace(pattern = "(</topes-legales>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<tope-legal ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3")) %>% 
   separate(x, sep = "@",
            into = c("id_tipo_compra", "fecha_desde", "comun", "ampliado")) %>% 
   mutate(id_tipo_compra = str_replace_all(string = id_tipo_compra, pattern = "^(id-tipo-compra=\")|(\")", replacement = ""),
          fecha_desde = lubridate::dmy(str_replace_all(string = fecha_desde, pattern = "^(fecha-desde=\")|(\")", replacement = "")),
          comun = as.numeric(str_replace_all(string = comun, pattern = "^(comun=\")|(\")", replacement = "")),
          ampliado = as.numeric(str_replace_all(string = ampliado, pattern = "[^0-9]", replacement = ""))) %>% 
   filter(!is.na(fecha_desde))
write_rds(topes_legales, path = "Data/rds/meta_topes_legales.rds")

## Unidades de compra centralizadas ##
url_unidades_compra_centralizada <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteUCCs.do"
unidades_compra_centralizada <- read_lines(url_unidades_compra_centralizada, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<unidades-compra-centralizadas>)", replacement = "") %>% 
   str_replace(pattern = "(</unidades-compra-centralizadas>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<unidad-compra-centralizada ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3")) %>% 
   separate(x, sep = "@",
            into = c("id_ucc", "nom_ucc")) %>% 
   mutate(id_ucc = as.numeric(str_replace_all(string = id_ucc, pattern = "[^0-9]", replacement = "")),
          nom_ucc = str_replace_all(string = nom_ucc, pattern = "^(nom-ucc=\")|(\"\\s/>)", replacement = "")) %>% 
   filter(!is.na(nom_ucc))
write_rds(unidades_compra_centralizada, path = "Data/rds/meta_id_ucc.rds")

## Unidades ejecutoras ##
url_unidades_ejecutoras <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteUnidadesEjecutoras.do"
unidades_ejecutoras <- read_lines(url_unidades_ejecutoras, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<unidades-ejecutoras>)", replacement = "") %>% 
   str_replace(pattern = "(</unidades-ejecutoras>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<unidad-ejecutora ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3")) %>% 
   separate(x, sep = "@",
            into = c("id_inciso", "id_ue", "nom_ue")) %>% 
   mutate(id_inciso = as.numeric(str_replace_all(string = id_inciso, pattern = "[^0-9]", replacement = "")),
          id_ue = as.numeric(str_replace_all(string = id_ue, pattern = "[^0-9]", replacement = "")),
          nom_ue = str_replace_all(string = nom_ue, pattern = "^(nom-ue=\")|(\"\\s/>)", replacement = "")) %>% 
   filter(!is.na(id_ue))
write_rds(unidades_ejecutoras, path = "Data/rds/meta_id_ue.rds")

## Unidades ejecutoras tope ampliado ##
url_ues_topes_ampliados <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteUETopesAmpliados.do"
ues_topes_ampliados <- read_lines(url_ues_topes_ampliados, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<ues-topes-ampliados>)", replacement = "") %>% 
   str_replace(pattern = "(</ues-topes-ampliados>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<ue-tope-ampliado ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3")) %>% 
   separate(x, sep = "@",
            into = c("id_inciso", "id_ue", "fecha_desde")) %>% 
   mutate(id_inciso = as.numeric(str_replace_all(string = id_inciso, pattern = "[^0-9]", replacement = "")),
          id_ue = as.numeric(str_replace_all(string = id_ue, pattern = "[^0-9]", replacement = "")),
          fecha_desde = lubridate::dmy(str_replace_all(string = fecha_desde, pattern = "^(fecha-desde=\")|(\"\\s/>)", replacement = ""))) %>% 
   filter(!is.na(id_ue))
write_rds(ues_topes_ampliados, path = "Data/rds/meta_ues_topes_ampliados.rds")

## Unidades de medida ##
url_unidades_medida <- "https://www.comprasestatales.gub.uy/comprasenlinea/jboss/reporteUnidadesMedida.do"
unidades_medida <- read_lines(url_unidades_medida, locale = locale(encoding = "Latin1"))[3] %>% 
   str_replace(pattern = "^(<unidades-medida>)", replacement = "") %>% 
   str_replace(pattern = "(</unidades-medida>)$", replacement = "") %>% 
   str_replace_all(pattern = "/>", replacement = "/>\\\n") %>% 
   str_split(pattern = "\\n") %>% 
   .[[1]] %>% 
   tibble(x = .) %>% 
   mutate(x = str_replace(string = x, pattern = "<unidades-medida ", replacement = ""),
          x = str_replace_all(string = x, pattern = "(\")([[:space:]])([a-z])", replacement = "\\1@\\3"),
          x = if_else(str_detect(string = x, pattern = "fecha-baja") == FALSE,
                      str_replace(string = x, pattern = "\"(\\s/>)$", replacement = "\"@@\\1"), x)) %>% 
   separate(x, sep = "@",
            into = c("cod", "descripcion", "fecha_baja", "motivo_baja")) %>% 
   mutate(cod = as.numeric(str_replace_all(string = cod, pattern = "[^0-9]", replacement = "")),
          descripcion = str_replace_all(string = descripcion, pattern = "^(descripcion=\")|(\")", replacement = ""),
          fecha_baja = lubridate::dmy(str_replace_all(string = fecha_baja, pattern = "^(fecha-baja=\")|(\")", replacement = "")),
          motivo_baja = str_replace_all(string = motivo_baja, pattern = "^(motivo-baja=\")|(\"\\s/>)$|(\\s/>)$", replacement = "")) %>% 
   filter(!is.na(cod))
write_rds(unidades_medida, path = "Data/rds/meta_id_unidad.rds")

# Tasas de cambio
tipo_de_cambio <- readxl::read_xls("Data/Csv/ReporteTasasDeCambio_11-10-18.xls", sheet = 1) %>% 
   rename(id_moneda = `Cod.moneda`,
          moneda = Moneda,
          fecha = `Fecha Tasa`,
          tasa = `Tasa de Cambio`) %>% 
   mutate(fecha = lubridate::dmy(fecha),
          id_moneda = as.factor(id_moneda))

## Base de compras ##
# Agrega información de otras tablas
# Ordena la base
# Codifica las variables
# Convierte monedas
# Quita compras con montos cero o negativos
# Filtra compras anteriores a 2017
#compras <- readr::read_csv("Data/Csv/comprasEstatalesrefactor.csv", col_types = c("dcccdccccdddcdddcdcccd")) %>% 
compras <- readr::read_csv("Data/Csv/comprasEstatalesrefactor.csv", col_types = cols(id_ucc = col_integer())) %>%
   left_join(estados_compra, by = c("id_estado_compra" = "id_estado_compra")) %>% 
   left_join(incisos, by = c("id_inciso" = "inciso")) %>% 
   left_join(select(monedas, id_moneda, desc_moneda), by = c("id_moneda" = "id_moneda")) %>% 
   left_join(select(tipos_compra, id, descripcion), by = c("id_tipo_compra" = "id")) %>% 
   left_join(unidades_ejecutoras, by = c("id_inciso" = "id_inciso", "id_ue" = "id_ue")) %>% 
   left_join(rename(tipos_resolucion, tipo_resol = descripcion), by = c("id_tipo_resol" = "id")) %>% 
   rename(estado_compra = descripcion.x,
          inciso = nom_inciso,
          moneda = desc_moneda,
          tipo_compra = descripcion.y,
          ue = nom_ue) %>% 
   select(-X1, apel, arch_adj, es_reiteracion, id_estado_compra, estado_compra, starts_with("fecha"), fondos_rotatorios, 
          id_compra, id_inciso, inciso, id_ue, ue, id_moneda, moneda, num_resol, id_tipo_resol, tipo_resol, 
          id_tipo_compra, tipo_compra, everything()) %>% 
   mutate(es_reiteracion = fct_recode(es_reiteracion, "N" = "No", "S" = "Yes"),
          id_estado_compra = factor(id_estado_compra, levels = estados_compra$id_estado_compra),
          fecha_compra = lubridate::ymd(fecha_compra),
          fecha_pub_adj = lubridate::ymd_hms(fecha_pub_adj),
          fondos_rotatorios = fct_recode(fondos_rotatorios, "N" = "No", "S" = "Yes"),
          id_inciso = factor(id_inciso, levels = incisos$inciso),
          id_moneda = factor(id_moneda, levels = monedas$id_moneda),
          id_tipo_resol = factor(id_tipo_resol, levels = tipos_resolucion$id),
          id_tipo_compra = factor(id_tipo_compra, levels = tipos_compra$id),
          subtipo_compra = as.factor(subtipo_compra)) %>% 
   left_join(select(tipo_de_cambio, -moneda), by = c("id_moneda", "fecha_compra" = "fecha")) %>% 
   arrange(id_moneda, fecha_compra) %>%
   mutate(tasa = if_else(id_moneda == 0, 1, tasa),
          tasa = zoo::na.locf(tasa),
          monto_adj_pesos = monto_adj * tasa) %>% 
   filter(monto_adj > 0, fecha_compra > "2018-01-01") %>%
  mutate(trimestre = ifelse(fecha_compra < "2018-04-01", "2018_01", ifelse( fecha_compra <"2018-07-01", "2018_02", ifelse(fecha_compra <"2018-10-01", "2018_03", ifelse( fecha_compra <"2019-01-01", "2018_04", "2019_01")))), 
         pesos_uruguayo = ifelse(id_moneda == 0 , "pesos_uruguayo", "otra_moneda"),
         span = (fecha_compra %--% fecha_pub_adj) %/% hours(1))



# Variable classes
# tibble(variables = names(sapply(compras, class))
#        classes = sapply(compras, class)) %>%s
#    unnest() %>% 
#    mutate(classes = if_else(classes == "POSIXct" | classes == "POSIXt", "Datetime", classes)) %>%
#    count(classes)

# adjudicaciones -> detalle de la compra (de la factura)
adjudicaciones <- readr::read_csv("Data/Csv/comprasEstatalesAdjudicacionesrefactor.csv") %>% 
   left_join(select(monedas, id_moneda, desc_moneda), by = "id_moneda") %>% 
   inner_join(select(compras, fecha_compra, id_compra, id_inciso,inciso), by = "id_compra") %>% 
   mutate(id_moneda = factor(id_moneda, levels = monedas$id_moneda)) %>% 
   left_join(select(tipo_de_cambio, -moneda), by = c("id_moneda", "fecha_compra" = "fecha")) %>% 
   mutate(tasa = if_else(id_moneda == 0, 1, tasa),
         tasa = zoo::na.locf(tasa),
         monto_adj_pesos = precio_tot_imp * tasa,
         monto_adj_pesos_unit = precio_unit * tasa)
write_rds(adjudicaciones, path = "Data/rds/adjudicaciones.rds")

# oferentes -> todos los que participaron 
oferentes <- readr::read_csv("Data/Csv/comprasEstatalesOferentesrefactor.csv")
oferentes <- rbind.data.frame(adjudicaciones %>% 
                                group_by(id_compra, nombre_comercial) %>% 
                                select(id_compra, nombre_comercial, monto_adj_pesos, nro_doc_prov) %>% 
                                left_join(oferentes, by="id_compra") %>% 
                                filter(is.na(nombre_comercial.y)) %>% 
                                select(id_compra, nombre_comercial.x, nro_doc_prov.x) %>% 
                                mutate(key_id = 1, tipo_doc_prov="R") %>% 
                                rename(nombre_comercial=nombre_comercial.x, nro_doc_prov=nro_doc_prov.x),oferentes)
write_rds(oferentes, path = "Data/rds/oferentes.rds")

# join compras con cantidad de articulo adjudicados y cantidad de oferentes si hay

compras <- compras %>% 
  left_join(adjudicaciones %>% group_by(id_compra) %>% summarise(arti_max = max(key_id)) , by="id_compra") %>%
  left_join(oferentes %>% group_by(id_compra) %>% summarise(oferentes_max = max(key_id)) , by="id_compra")
write_rds(compras, path = "Data/rds/compras.rds")

#################################
##### FIN DE LA PROGRAMACIÓN ####
#################################