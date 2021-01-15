class CreateGamificationTriggers < ActiveRecord::Migration[5.0]
  def change

	reversible do |dir|
		dir.up do
			execute <<-SQL
				CREATE OR REPLACE FUNCTION gamification_create_debate() RETURNS trigger
				LANGUAGE plpgsql AS 
				$$DECLARE
					_GAMIFICATION_KEY 	constant varchar := 'PARTICIPA';
					_ACTION_KEY 		constant varchar := 'CREAR_DEBATE';
					_PROCESS_TYPE 		constant varchar := 'Debate';
					_gamification_id 	integer;
					_action_id 			integer;
					_action_score 		integer;
				BEGIN
					select id 
					into _gamification_id
					from gamifications 
					where key = _GAMIFICATION_KEY;

					select id, score
					into _action_id, _action_score
					from gamification_actions
					where gamification_id = _gamification_id
					and key = _ACTION_KEY;

					INSERT INTO gamification_user_rankings (user_id, gamification_id, score, created_at, updated_at)
					VALUES(NEW.author_id, _gamification_id, _action_score, NEW.created_at, NEW.updated_at) 
					ON CONFLICT (user_id, gamification_id) 
					DO 
					   UPDATE SET score = COALESCE(gamification_user_rankings.score, 0) + COALESCE(_action_score, 0), updated_at = NEW.updated_at;

					INSERT into gamification_user_actions (user_id, gamification_action_id, score, process_type, process_id, created_at, updated_at)
					values (NEW.author_id, _action_id, _action_score, _PROCESS_TYPE, NEW.id, NEW.created_at, NEW.updated_at);
					
					RETURN NEW;
				END;$$;

				CREATE OR REPLACE FUNCTION gamification_create_vote() RETURNS trigger
				LANGUAGE plpgsql AS 
				$$DECLARE
					_GAMIFICATION_KEY 		constant varchar := 'PARTICIPA';
					_ACTION_KEY_DEBATE		constant varchar := 'VOTAR_DEBATE';
					_ACTION_KEY_PROPOSAL 	constant varchar := 'APOYAR_PROPUESTA';
					_gamification_id 	integer;
					_action_id 			integer;
					_action_score 		integer;
					_additional_score 	integer;
				BEGIN
					select id 
					into _gamification_id
					from gamifications 
					where key = _GAMIFICATION_KEY;
					
					if NEW.voter_type = 'User' then
						if NEW.votable_type = 'Debate' then
							select id, score
							into _action_id, _action_score
							from gamification_actions
							where gamification_id = _gamification_id
							and key = _ACTION_KEY_DEBATE;

							select additional_score
							into _additional_score
							from gamification_action_additional_scores
							where gamification_action_id = _action_id
							and process_type = NEW.votable_type
							and process_id = NEW.votable_id;

							INSERT INTO gamification_user_rankings (user_id, gamification_id, score, created_at, updated_at)
							VALUES(NEW.voter_id, _gamification_id, COALESCE(_action_score, 0) + COALESCE(_additional_score, 0), NEW.created_at, NEW.updated_at) 
							ON CONFLICT (user_id, gamification_id) 
							DO 
							   UPDATE SET score = COALESCE(gamification_user_rankings.score, 0) + COALESCE(_action_score, 0) + COALESCE(_additional_score, 0), updated_at = NEW.updated_at;

							INSERT into gamification_user_actions (user_id, gamification_action_id, score, additional_score, process_type, process_id, created_at, updated_at)
							values (NEW.voter_id, _action_id, _action_score, _additional_score, NEW.votable_type, NEW.votable_id, NEW.created_at, NEW.updated_at);

						elsif NEW.votable_type = 'Proposal' then
							-- Ver si la propuesta está asociada a un proceso
							-- xxxxxxxxxxxx
						end if;
					end if;

					RETURN NEW;
				END;$$;

				CREATE OR REPLACE FUNCTION gamification_create_comment() RETURNS trigger
				LANGUAGE plpgsql AS 
				$$DECLARE
					_GAMIFICATION_KEY 		constant varchar := 'PARTICIPA';
					_ACTION_KEY_DEBATE		constant varchar := 'COMENTAR_DEBATE';
					_ACTION_KEY_PROPOSAL 	constant varchar := 'COMENTAR_PROPUESTA';
					-- _ACTION_KEY_****
					_gamification_id 	integer;
					_action_id 			integer;
					_action_score 		integer;
					_additional_score 	integer;
				BEGIN
					select id 
					into _gamification_id
					from gamifications 
					where key = _GAMIFICATION_KEY;
					
					if NEW.commentable_type = 'Debate' then
						select id, score
						into _action_id, _action_score
						from gamification_actions
						where gamification_id = _gamification_id
						and key = _ACTION_KEY_DEBATE;

						select additional_score
						into _additional_score
						from gamification_action_additional_scores
						where gamification_action_id = _action_id
						and process_type = NEW.commentable_type
						and process_id = NEW.commentable_id;

						INSERT INTO gamification_user_rankings (user_id, gamification_id, score, created_at, updated_at)
						VALUES(NEW.user_id, _gamification_id, COALESCE(_action_score, 0) + COALESCE(_additional_score, 0), NEW.created_at, NEW.updated_at) 
						ON CONFLICT (user_id, gamification_id) 
						DO 
						   UPDATE SET score = COALESCE(gamification_user_rankings.score, 0) + COALESCE(_action_score, 0) + COALESCE(_additional_score, 0), updated_at = NEW.updated_at;

						INSERT into gamification_user_actions (user_id, gamification_action_id, score, additional_score, process_type, process_id, created_at, updated_at)
						values (NEW.user_id, _action_id, _action_score, _additional_score, NEW.commentable_type, NEW.commentable_id, NEW.created_at, NEW.updated_at);

					elsif NEW.commentable_type = 'Proposal' then
						-- Ver si la propuesta está asociada a un proceso
						-- xxxxxxxxxxxx
					-- elsif *****
					end if;

					RETURN NEW;
				END;$$;

				CREATE TRIGGER insert_debate
					AFTER INSERT ON debates
					FOR EACH ROW EXECUTE PROCEDURE gamification_create_debate();

				CREATE TRIGGER insert_vote
					AFTER INSERT ON votes
					FOR EACH ROW EXECUTE PROCEDURE gamification_create_vote();

				CREATE TRIGGER insert_comment
					AFTER INSERT ON comments
					FOR EACH ROW EXECUTE PROCEDURE gamification_create_comment();
			SQL
	   	end

		dir.down do
			execute <<-SQL
				DROP TRIGGER insert_debate ON debates;
				DROP TRIGGER insert_vote ON votes;
				DROP TRIGGER insert_comment ON comments;
			SQL
		end
	end

  end
end
