class CreateForums < ActiveRecord::Migration[5.0]
  def change
  	
	  create_table "forum_translations", force: :cascade do |t|
	    t.integer  "forum_id",   null: false
	    t.string   "locale",      null: false
	    t.datetime "created_at",  null: false
	    t.datetime "updated_at",  null: false
	    t.string   "title"
	    t.text     "description"
	    t.datetime "hidden_at"
	    t.index ["forum_id"], name: "index_forum_translations_on_forum_id", using: :btree
	    t.index ["hidden_at"], name: "index_forum_translations_on_hidden_at", using: :btree
	    t.index ["locale"], name: "index_forum_translations_on_locale", using: :btree
	  end

	  create_table "forums", force: :cascade do |t|
	    t.string   "deprecated_title",             limit: 80
	    t.text     "deprecated_description"
	    t.integer  "author_id"
	    t.datetime "created_at",                                          null: false
	    t.datetime "updated_at",                                          null: false
	    t.string   "visit_id"
	    t.datetime "hidden_at"
	    t.integer  "flags_count",                             default: 0
	    t.datetime "ignored_flag_at"
	    t.integer  "cached_votes_total",                      default: 0
	    t.integer  "cached_votes_up",                         default: 0
	    t.integer  "cached_votes_down",                       default: 0
	    t.integer  "comments_count",                          default: 0
	    t.datetime "confirmed_hide_at"
	    t.integer  "cached_anonymous_votes_total",            default: 0
	    t.integer  "cached_votes_score",                      default: 0
	    t.bigint   "hot_score",                               default: 0
	    t.integer  "confidence_score",                        default: 0
	    t.integer  "geozone_id"
	    t.tsvector "tsv"
	    t.datetime "featured_at"
	    t.index ["author_id", "hidden_at"], name: "index_forums_on_author_id_and_hidden_at", using: :btree
	    t.index ["author_id"], name: "index_forums_on_author_id", using: :btree
	    t.index ["cached_votes_down"], name: "index_forums_on_cached_votes_down", using: :btree
	    t.index ["cached_votes_score"], name: "index_forums_on_cached_votes_score", using: :btree
	    t.index ["cached_votes_total"], name: "index_forums_on_cached_votes_total", using: :btree
	    t.index ["cached_votes_up"], name: "index_forums_on_cached_votes_up", using: :btree
	    t.index ["confidence_score"], name: "index_forums_on_confidence_score", using: :btree
	    t.index ["geozone_id"], name: "index_forums_on_geozone_id", using: :btree
	    t.index ["hidden_at"], name: "index_forums_on_hidden_at", using: :btree
	    t.index ["hot_score"], name: "index_forums_on_hot_score", using: :btree
	    t.index ["tsv"], name: "index_forums_on_tsv", using: :gin
	  end

  end
end
