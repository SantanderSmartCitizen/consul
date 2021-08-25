
municipal_areas = [
	{
		title_es: "Viabilidad",
		title_en: "Feasibility",
	},
	{
		title_es: "Cultura",
		title_en: "Culture",
	},
	{
		title_es: "Medio ambiente",
		title_en: "Environment",
	},
	{
		title_es: "Ingeniería industrial",
		title_en: "Industrial engineering",
	},
	{
		title_es: "Turismo",
		title_en: "Tourism",
	},
	{
		title_es: "Protección civil",
		title_en: "Civil protection",
	},
	{
		title_es: "Transporte",
		title_en: "Transport",
	},
	{
		title_es: "Servicios generales",
		title_en: "General services",
	}
]

municipal_areas.each do |municipal_area_attributes|
	MunicipalArea.create!(municipal_area_attributes)
end
