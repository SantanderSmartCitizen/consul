
gamifications = [
	{
		key: "PARTICIPA", locked: true,
		title_es: "Módulo de participación", description_es: "Gamificación utlizada en la plataforma de participación ciudadana.",
		title_en: "Participation module", description_en: "Gamification used in the citizen participation platform.",
		actions_attributes: [
			{
				key: "CREAR_DEBATE", score: 20, process_type: "Debate", operation: "create",
				title_es: "Crear debate", description_es: "Acción para crear debate",
				title_en: "Create debate", description_en: "Action to create debate"
			},
			{
				key: "VOTAR_DEBATE", score: 10, process_type: "Debate", operation: "vote",
				title_es: "Votar debate", description_es: "Acción para votar debate",
				title_en: "Vote debate", description_en: "Action to vote debate"
			},
			{
				key: "COMENTAR_DEBATE", score: 1, process_type: "Debate", operation: "comment",
				title_es: "Comentar debate", description_es: "Acción para comentar debate",
				title_en: "Comment debate", description_en: "Action to comment debate"
			},
			{
				key: "CREAR_PROPUESTA", score: 20, process_type: "Proposal", operation: "create",
				title_es: "Crear propuesta", description_es: "Acción para crear propuesta",
				title_en: "Create proposal", description_en: "Action to create proposal"
			},
			{
				key: "APOYAR_PROPUESTA", score: 10, process_type: "Proposal", operation: "support", 
				title_es: "Apoyar propuesta", description_es: "Acción para apoyar propuesta",
				title_en: "Vote proposal", description_en: "Action to vote proposal"
			},
			{
				key: "COMENTAR_PROPUESTA", score: 1, process_type: "Proposal", operation: "comment", 
				title_es: "Comentar propuesta", description_es: "Acción para comentar propuesta",
				title_en: "Comment proposal", description_en: "Action to comment proposal"
			},
			{
				key: "RESPONDER_ENCUESTA", score: 2, process_type: "Poll", operation: "answer_question",
				title_es: "Responder encuesta\/consulta", description_es: "Acción para responder encuesta\/consulta",
				title_en: "Answer poll\/question", description_en: "Action to answer poll\/question"
			},
			{
				key: "COMENTAR_ENCUESTA", score: 1, process_type: "Poll", operation: "comment", 
				title_es: "Comentar encuesta\/consulta", description_es: "Acción para comentar encuesta\/consulta",
				title_en: "Comment poll\/question", description_en: "Action to comment poll\/question"
			},
			{
				key: "CREAR_PROY_GASTO", score: 20, process_type: "Budget::Investment", operation: "create", 
				title_es: "Crear proyecto de gasto", description_es: "Acción para crear proyecto de gasto",
				title_en: "Create budget investment", description_en: "Action to create budget investment"
			},
			{
				key: "PROC_COMENTAR_DEBATE", score: 10, process_type: "Legislation::Process", operation: "comment_debate", 
				title_es: "Comentar debate en proceso", description_es: "Acción para comentar debate en proceso",
				title_en: "Comment debate in process", description_en: "Action to comment debate in process"
			},
			{
				key: "PROC_CREAR_PROPUESTA", score: 20, process_type: "Legislation::Process", operation: "create_proposal", 
				title_es: "Crear propuesta en proceso", description_es: "Acción para crear propuesta en proceso",
				title_en: "Create proposal in process", description_en: "Action to create proposal in process"
			},
			{
				key: "PROC_APOYAR_PROPUESTA", score: 10, process_type: "Legislation::Process", operation: "support_proposal", 
				title_es: "Apoyar propuesta en proceso", description_es: "Acción para apoyar propuesta en proceso",
				title_en: "Vote proposal in process", description_en: "Action to vote proposal in process"
			},
			{
				key: "PROC_COMENTAR_PROPUESTA", score: 1, process_type: "Legislation::Process", operation: "comment_proposal", 
				title_es: "Comentar propuesta en proceso", description_es: "Acción para comentar propuesta en proceso",
				title_en: "Comment proposal in process", description_en: "Action to comment proposal in process"
			},
			{
				key: "PROC_COMENTAR_TEXTO", score: 10, process_type: "Legislation::Process", operation: "comment", 
				title_es: "Comentar texto en proceso", description_es: "Acción para comentar texto en proceso",
				title_en: "Comment text in process", description_en: "Action to comment text in process"
			},
			{
				key: "CREAR_TEMA_FORO", score: 20, process_type: "Forum", operation: "create", 
				title_es: "Crear tema en el foro", description_es: "Acción para crear tema en el foro",
				title_en: "Create topic in forum", description_en: "Action to create topic in forum"
			},
			{
				key: "COMENTAR_TEMA_FORO", score: 1, process_type: "Forum", operation: "comment", 
				title_es: "Comentar tema en el foro", description_es: "Acción para comentar tema en el foro",
				title_en: "Comment topic in forum", description_en: "Action to comment topic in forum"
			}
		],
		rewards_attributes: [
			{
				minimum_score: 100, active: true, request_to_administrators: true,
				title_es: "Bronce", description_es: "Recompensa bronce",
				title_en: "Bronze", description_en: "Bronze reward"
			},
			{
				minimum_score: 500, active: true, request_to_administrators: true,
				title_es: "Plata", description_es: "Recompensa plata",
				title_en: "Silver", description_en: "Silver reward"
			},
			{
				minimum_score: 1000, active: true, request_to_administrators: true,
				title_es: "Oro", description_es: "Recompensa oro",
				title_en: "Gold", description_en: "Gold reward"
			}
		]
	}
]

gamifications.each do |gamification_attributes|
	Gamification.where(key: gamification_attributes[:key]).first_or_create!(gamification_attributes)
end
