class CreateGamificationTriggers < ActiveRecord::Migration[5.0]
  def change

	reversible do |dir|
		dir.up do
			execute <<-SQL

			CREATE OR REPLACE FUNCTION insert_into_gamification_user(varchar,varchar,varchar,integer,integer,integer) RETURNS varchar
				LANGUAGE plpgsql AS 
				$$DECLARE
					-- Declare function argument aliases.
					_gamification_key 		ALIAS FOR $1;
					_action_process_type 	ALIAS FOR $2;
					_action_operation 		ALIAS FOR $3;
					_user_id 				ALIAS FOR $4;
					_process_id 			ALIAS FOR $5;
					_skip_additional_score	ALIAS FOR $6;

				    -- Declare variables
				    _gamification_id 	integer;
					_action_id 			integer;
					_action_score 		integer;
					_additional_score 	integer;
				BEGIN
					select id 
					into _gamification_id
					from gamifications 
					where key = _gamification_key;

					if _gamification_id IS NULL then
						RETURN 'GAMIFICATION_NOT_FOUND';
					end if;

					select id, score
					into _action_id, _action_score
					from gamification_actions
					where gamification_id = _gamification_id
					and process_type = _action_process_type
					and operation = _action_operation;

					if _action_id IS NULL then
						RETURN 'ACTION_NOT_FOUND';
					end if;

					if _skip_additional_score = 0 then
						select additional_score
						into _additional_score
						from gamification_action_additional_scores
						where gamification_action_id = _action_id
						and process_type = _action_process_type
						and process_id = _process_id;
					end if;

					INSERT INTO gamification_user_rankings (user_id, gamification_id, score, created_at, updated_at)
					VALUES(_user_id, _gamification_id, COALESCE(_action_score, 0) + COALESCE(_additional_score, 0), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) 
					ON CONFLICT (user_id, gamification_id) 
					DO 
					   UPDATE SET score = COALESCE(gamification_user_rankings.score, 0) + COALESCE(_action_score, 0) + COALESCE(_additional_score, 0), updated_at = CURRENT_TIMESTAMP;

					INSERT into gamification_user_actions (user_id, gamification_action_id, score, additional_score, process_type, process_id, created_at, updated_at)
					values (_user_id, _action_id, _action_score, _additional_score, _action_process_type, _process_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
					
					RETURN 'OK';
					
				END;$$;

				CREATE OR REPLACE FUNCTION insert_into_gamification_user_from_api(varchar,varchar,integer,varchar,integer) RETURNS varchar
				LANGUAGE plpgsql AS 
				$$DECLARE
					-- Declare function argument aliases.
					_gamification_key 	ALIAS FOR $1;
					_action_key 		ALIAS FOR $2;
					_user_id 			ALIAS FOR $3;
					_process_type 		ALIAS FOR $4;
					_process_id 		ALIAS FOR $5;

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
						RETURN 'GAMIFICATION_NOT_FOUND';
					end if;

					select id, score
					into _action_id, _action_score
					from gamification_actions
					where gamification_id = _gamification_id
					and key = _action_key;

					if _action_id IS NULL then
						RETURN 'ACTION_NOT_FOUND';
					end if;

					INSERT INTO gamification_user_rankings (user_id, gamification_id, score, created_at, updated_at)
					VALUES(_user_id, _gamification_id, COALESCE(_action_score, 0), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) 
					ON CONFLICT (user_id, gamification_id) 
					DO 
					   UPDATE SET score = COALESCE(gamification_user_rankings.score, 0) + COALESCE(_action_score, 0), updated_at = CURRENT_TIMESTAMP;

					INSERT into gamification_user_actions (user_id, gamification_action_id, score, process_type, process_id, created_at, updated_at)
					values (_user_id, _action_id, _action_score, _process_type, _process_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
					
					RETURN 'OK';
					
				END;$$;

				CREATE OR REPLACE FUNCTION gamification_create_debate() RETURNS trigger
				LANGUAGE plpgsql AS 
				$$DECLARE
					_GAMIFICATION_KEY 		constant varchar := 'PARTICIPA';
					_PROCESS_TYPE 			constant varchar := 'Debate';
					_OPERATION 				constant varchar := 'create';
					_SKIP_ADDITIONAL_SCORE 	constant integer := 1;
				BEGIN
					
					PERFORM insert_into_gamification_user(_GAMIFICATION_KEY, _PROCESS_TYPE, _OPERATION, NEW.author_id, NEW.id, _SKIP_ADDITIONAL_SCORE);

					RETURN NEW;
				END;$$;

				CREATE OR REPLACE FUNCTION gamification_create_proposal() RETURNS trigger
				LANGUAGE plpgsql AS 
				$$DECLARE
					_GAMIFICATION_KEY 		constant varchar := 'PARTICIPA';
					_PROCESS_TYPE 			constant varchar := 'Proposal';
					_OPERATION 				constant varchar := 'create';
					_SKIP_ADDITIONAL_SCORE 	constant integer := 1;
				BEGIN
					
					PERFORM insert_into_gamification_user(_GAMIFICATION_KEY, _PROCESS_TYPE, _OPERATION, NEW.author_id, NEW.id, _SKIP_ADDITIONAL_SCORE);

					RETURN NEW;
				END;$$;

				CREATE OR REPLACE FUNCTION gamification_create_legislation_proposal() RETURNS trigger
				LANGUAGE plpgsql AS 
				$$DECLARE
					_GAMIFICATION_KEY 		constant varchar := 'PARTICIPA';
					_PROCESS_TYPE 			constant varchar := 'Legislation::Process';
					_OPERATION 				constant varchar := 'create_proposal';
					_SKIP_ADDITIONAL_SCORE 	constant integer := 1;
				BEGIN
					
					PERFORM insert_into_gamification_user(_GAMIFICATION_KEY, _PROCESS_TYPE, _OPERATION, NEW.author_id, NEW.legislation_process_id, _SKIP_ADDITIONAL_SCORE);

					RETURN NEW;
				END;$$;

				CREATE OR REPLACE FUNCTION gamification_create_forum() RETURNS trigger
				LANGUAGE plpgsql AS 
				$$DECLARE
					_GAMIFICATION_KEY 		constant varchar := 'PARTICIPA';
					_PROCESS_TYPE 			constant varchar := 'Forum';
					_OPERATION 				constant varchar := 'create';
					_SKIP_ADDITIONAL_SCORE 	constant integer := 1;
				BEGIN
					
					PERFORM insert_into_gamification_user(_GAMIFICATION_KEY, _PROCESS_TYPE, _OPERATION, NEW.author_id, NEW.id, _SKIP_ADDITIONAL_SCORE);

					RETURN NEW;
				END;$$;

				CREATE OR REPLACE FUNCTION gamification_create_budget_investment() RETURNS trigger
				LANGUAGE plpgsql AS 
				$$DECLARE
					_GAMIFICATION_KEY 		constant varchar := 'PARTICIPA';
					_PROCESS_TYPE 			constant varchar := 'Budget::Investment';
					_OPERATION 				constant varchar := 'create';
					_SKIP_ADDITIONAL_SCORE 	constant integer := 1;
				BEGIN
					
					PERFORM insert_into_gamification_user(_GAMIFICATION_KEY, _PROCESS_TYPE, _OPERATION, NEW.author_id, NEW.id, _SKIP_ADDITIONAL_SCORE);

					RETURN NEW;
				END;$$;

				CREATE OR REPLACE FUNCTION gamification_answer_question() RETURNS trigger
				LANGUAGE plpgsql AS 
				$$DECLARE
					_GAMIFICATION_KEY 		constant varchar := 'PARTICIPA';
					_PROCESS_TYPE 			constant varchar := 'Poll';
					_OPERATION 				constant varchar := 'answer_question';
					_SKIP_ADDITIONAL_SCORE 	constant integer := 0;
					_process_id 			integer;
				BEGIN
					
					select pq.poll_id
					into _process_id
					from poll_questions pq
					where pq.id = (
						select pa.question_id
						from poll_answers pa
						where pa.id = NEW.id
					);

					PERFORM insert_into_gamification_user(_GAMIFICATION_KEY, _PROCESS_TYPE, _OPERATION, NEW.author_id, _process_id, _SKIP_ADDITIONAL_SCORE);

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
					_SKIP_ADDITIONAL_SCORE 			constant integer := 0;
					_action_process_type 			varchar;
					_action_operation 				varchar;
					_process_id 					integer;
				BEGIN
					
					if NEW.voter_type = 'User' then

						case NEW.votable_type
							when _TYPE_PROPOSAL then
								_action_process_type = _TYPE_PROPOSAL;
								_action_operation = _OPERATION_PROPOSAL;
								_process_id = NEW.votable_id;
							when _TYPE_LEGISLATION_PROPOSAL then
								_action_process_type = _TYPE_LEGISLATION_PROCESS;
								_action_operation = _OPERATION_LEGISLATION_PROPOSAL;
								select lp.legislation_process_id
								into _process_id
								from legislation_proposals lp
								where lp.id = NEW.votable_id;
							else
								_action_process_type = NEW.votable_type;
								_action_operation = _OPERATION;
								_process_id = NEW.votable_id;
						end case;

						PERFORM insert_into_gamification_user(_GAMIFICATION_KEY, _action_process_type, _action_operation, NEW.voter_id, _process_id, _SKIP_ADDITIONAL_SCORE);

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
					_OPERATION_LEGISLATION_QUESTION	constant varchar := 'comment_debate';
					_OPERATION_LEGISLATION_PROPOSAL	constant varchar := 'comment_proposal';
					_SKIP_ADDITIONAL_SCORE 			constant integer := 0;
					_action_process_type 			varchar;
					_action_operation 				varchar;
					_process_id 					integer;
				BEGIN
					
					case NEW.commentable_type
						when _TYPE_LEGISLATION_ANNOTATION then
							_action_process_type = _TYPE_LEGISLATION_PROCESS;
							_action_operation = _OPERATION;
							select ldv.legislation_process_id
							into _process_id
							from legislation_draft_versions ldv
							where ldv.id = (
								select la.legislation_draft_version_id
								from legislation_annotations la
								where la.id = NEW.commentable_id
							);
						when _TYPE_LEGISLATION_PROPOSAL then
							_action_process_type = _TYPE_LEGISLATION_PROCESS;
							_action_operation = _OPERATION_LEGISLATION_PROPOSAL;
							select lp.legislation_process_id
							into _process_id
							from legislation_proposals lp
							where lp.id = NEW.commentable_id;
						when _TYPE_LEGISLATION_QUESTION then
							_action_process_type = _TYPE_LEGISLATION_PROCESS;
							_action_operation = _OPERATION_LEGISLATION_QUESTION;
							select lq.legislation_process_id
							into _process_id
							from legislation_questions lq
							where lq.id = NEW.commentable_id;
						else
							_action_process_type = NEW.commentable_type;
							_action_operation = _OPERATION;
							_process_id = NEW.commentable_id;
					end case;

					PERFORM insert_into_gamification_user(_GAMIFICATION_KEY, _action_process_type, _action_operation, NEW.user_id, _process_id, _SKIP_ADDITIONAL_SCORE);

					RETURN NEW;
				END;$$;

				CREATE TRIGGER insert_debate
					AFTER INSERT ON debates
					FOR EACH ROW EXECUTE PROCEDURE gamification_create_debate();

				CREATE TRIGGER insert_proposal
					AFTER INSERT ON proposals
					FOR EACH ROW EXECUTE PROCEDURE gamification_create_proposal();

				CREATE TRIGGER insert_legislation_proposal
					AFTER INSERT ON legislation_proposals
					FOR EACH ROW EXECUTE PROCEDURE gamification_create_legislation_proposal();

				CREATE TRIGGER insert_forum
					AFTER INSERT ON forums
					FOR EACH ROW EXECUTE PROCEDURE gamification_create_forum();

				CREATE TRIGGER insert_budget_investment
					AFTER INSERT ON budget_investments
					FOR EACH ROW EXECUTE PROCEDURE gamification_create_budget_investment();

				CREATE TRIGGER insert_poll_answer
					AFTER INSERT ON poll_answers
					FOR EACH ROW EXECUTE PROCEDURE gamification_answer_question();

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
				DROP TRIGGER insert_proposal ON proposals;
				DROP TRIGGER insert_legislation_proposal ON legislation_proposals;
				DROP TRIGGER insert_forum ON forums;
				DROP TRIGGER insert_budget_investment ON budget_investments;
				DROP TRIGGER insert_poll_answer ON poll_answers;
				DROP TRIGGER insert_vote ON votes;
				DROP TRIGGER insert_comment ON comments;
			SQL
		end
	end

  end
end
