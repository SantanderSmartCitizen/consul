class CreateGamificationTriggers < ActiveRecord::Migration[5.0]
  def change

	reversible do |dir|
		dir.up do
			execute <<-SQL

			CREATE OR REPLACE FUNCTION insert_into_gamification_user(varchar,varchar,varchar,integer, integer) RETURNS integer
				LANGUAGE plpgsql AS 
				$$DECLARE
					-- Declare function argument aliases.
					_gamification_key 		ALIAS FOR $1;
					_action_process_type 	ALIAS FOR $2;
					_action_operation 		ALIAS FOR $3;
					_user_id 				ALIAS FOR $4;
					_process_id 			ALIAS FOR $5;

				    -- Declare variables
				    _gamification_id 	integer;
					_action_id 			integer;
					_action_score 		integer;
				BEGIN
					select id 
					into _gamification_id
					from gamifications 
					where key = _gamification_key;

					if _gamification_id IS NULL then
						-- Return -1 if the gamification is not found.
						RETURN -1;
					end if;

					select id, score
					into _action_id, _action_score
					from gamification_actions
					where gamification_id = _gamification_id
					and process_type = _action_process_type
					and operation = _action_operation;

					if _action_id IS NULL then
						-- Return -1 if the action is not found.
						RETURN -1;
					end if;

					INSERT INTO gamification_user_rankings (user_id, gamification_id, score, created_at, updated_at)
					VALUES(_user_id, _gamification_id, _action_score, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) 
					ON CONFLICT (user_id, gamification_id) 
					DO 
					   UPDATE SET score = COALESCE(gamification_user_rankings.score, 0) + COALESCE(_action_score, 0), updated_at = CURRENT_TIMESTAMP;

					INSERT into gamification_user_actions (user_id, gamification_action_id, score, process_type, process_id, created_at, updated_at)
					values (_user_id, _action_id, _action_score, _action_process_type, _process_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
					
					-- Return 1 to indicate the function was successful.
					RETURN 1;
					
				END;$$;

				CREATE OR REPLACE FUNCTION gamification_create_debate() RETURNS trigger
				LANGUAGE plpgsql AS 
				$$DECLARE
					_GAMIFICATION_KEY 	constant varchar := 'PARTICIPA';
					_PROCESS_TYPE 		constant varchar := 'Debate';
					_OPERATION 			constant varchar := 'create';
				BEGIN
					
					PERFORM insert_into_gamification_user(_GAMIFICATION_KEY, _PROCESS_TYPE, _OPERATION, NEW.author_id, NEW.id);

					RETURN NEW;
				END;$$;

				CREATE OR REPLACE FUNCTION gamification_create_vote() RETURNS trigger
				LANGUAGE plpgsql AS 
				$$DECLARE
					_GAMIFICATION_KEY 				constant varchar := 'PARTICIPA';
					_TYPE_PROPOSAL					constant varchar := 'Proposal';
					_TYPE_LEGISLATION_PROCESS 		constant varchar := 'Legislation::Process';
					_TYPE_LEGISLATION_PROPOSAL 		constant varchar := 'Legislation::Proposal';
					_OPERATION 						constant varchar := 'vote';
					_OPERATION_PROPOSAL				constant varchar := 'support';
					_OPERATION_LEGISLATION_PROPOSAL constant varchar := 'support_proposal';
					_gamification_id 				integer;
					_action_id 						integer;
					_action_score 					integer;
					_action_process_type 			varchar;
					_action_operation 				varchar;
					_additional_score 				integer;
				BEGIN
					
					if NEW.voter_type = 'User' then

						select id 
						into _gamification_id
						from gamifications 
						where key = _GAMIFICATION_KEY;

						case NEW.votable_type
							when _TYPE_PROPOSAL then
								_action_process_type = _TYPE_PROPOSAL;
								_action_operation = _OPERATION_PROPOSAL;
							when _TYPE_LEGISLATION_PROPOSAL then
								_action_process_type = _TYPE_LEGISLATION_PROCESS;
								_action_operation = _OPERATION_LEGISLATION_PROPOSAL;
							else
								_action_process_type = NEW.votable_type;
								_action_operation = _OPERATION;
						end case;

						select id, score
						into _action_id, _action_score
						from gamification_actions
						where gamification_id = _gamification_id
						and process_type = _action_process_type
						and operation = _action_operation;

						if _action_id IS NOT NULL then

							select additional_score
							into _additional_score
							from gamification_action_additional_scores
							where gamification_action_id = _action_id
							and process_type = _action_process_type
							and process_id = NEW.votable_id;

							INSERT INTO gamification_user_rankings (user_id, gamification_id, score, created_at, updated_at)
							VALUES(NEW.voter_id, _gamification_id, COALESCE(_action_score, 0) + COALESCE(_additional_score, 0), NEW.created_at, NEW.updated_at) 
							ON CONFLICT (user_id, gamification_id) 
							DO 
							   UPDATE SET score = COALESCE(gamification_user_rankings.score, 0) + COALESCE(_action_score, 0) + COALESCE(_additional_score, 0), updated_at = NEW.updated_at;

							INSERT into gamification_user_actions (user_id, gamification_action_id, score, additional_score, process_type, process_id, created_at, updated_at)
							values (NEW.voter_id, _action_id, _action_score, _additional_score, _action_process_type, NEW.votable_id, NEW.created_at, NEW.updated_at);
						
						end if;
					end if;

					RETURN NEW;
				END;$$;

				CREATE OR REPLACE FUNCTION gamification_create_comment() RETURNS trigger
				LANGUAGE plpgsql AS 
				$$DECLARE
					_GAMIFICATION_KEY 				constant varchar := 'PARTICIPA';
					_TYPE_LEGISLATION_PROCESS 		constant varchar := 'Legislation::Process';
					_TYPE_LEGISLATION_ANNOTATION 	constant varchar := 'Legislation::Annotation';
					_TYPE_LEGISLATION_PROPOSAL 		constant varchar := 'Legislation::Proposal';
					_TYPE_LEGISLATION_QUESTION 		constant varchar := 'Legislation::Question';
					_OPERATION 						constant varchar := 'comment';
					_OPERATION_DEBATE 				constant varchar := 'comment_debate';
					_OPERATION_PROPOSAL				constant varchar := 'comment_proposal';
					_gamification_id 				integer;
					_action_id 						integer;
					_action_score 					integer;
					_action_process_type 			varchar;
					_action_operation 				varchar;
					_additional_score 				integer;
				BEGIN
					select id 
					into _gamification_id
					from gamifications 
					where key = _GAMIFICATION_KEY;
					
					case NEW.commentable_type
						when _TYPE_LEGISLATION_ANNOTATION then
							_action_process_type = _TYPE_LEGISLATION_PROCESS;
							_action_operation = _OPERATION;
						when _TYPE_LEGISLATION_PROPOSAL then
							_action_process_type = _TYPE_LEGISLATION_PROCESS;
							_action_operation = _OPERATION_PROPOSAL;
						when _TYPE_LEGISLATION_QUESTION then
							_action_process_type = _TYPE_LEGISLATION_PROCESS;
							_action_operation = _OPERATION_DEBATE;
						else
							_action_process_type = NEW.commentable_type;
							_action_operation = _OPERATION;
					end case;
					
					select id, score
					into _action_id, _action_score
					from gamification_actions
					where gamification_id = _gamification_id
					and process_type = _action_process_type
					and operation = _action_operation;

					if _action_id IS NOT NULL then

						select additional_score
						into _additional_score
						from gamification_action_additional_scores
						where gamification_action_id = _action_id
						and process_type = _action_process_type
						and process_id = NEW.commentable_id;

						INSERT INTO gamification_user_rankings (user_id, gamification_id, score, created_at, updated_at)
						VALUES(NEW.user_id, _gamification_id, COALESCE(_action_score, 0) + COALESCE(_additional_score, 0), NEW.created_at, NEW.updated_at) 
						ON CONFLICT (user_id, gamification_id) 
						DO 
						   UPDATE SET score = COALESCE(gamification_user_rankings.score, 0) + COALESCE(_action_score, 0) + COALESCE(_additional_score, 0), updated_at = NEW.updated_at;

						INSERT into gamification_user_actions (user_id, gamification_action_id, score, additional_score, process_type, process_id, created_at, updated_at)
						values (NEW.user_id, _action_id, _action_score, _additional_score, _action_process_type, NEW.commentable_id, NEW.created_at, NEW.updated_at);

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
