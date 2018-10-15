"""empty message

Revision ID: 5b9b9d8b0878
Revises: 1a9ada47cbd6
Create Date: 2018-10-15 12:42:07.862324

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '5b9b9d8b0878'
down_revision = '1a9ada47cbd6'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('follow',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('user_id', sa.Integer(), nullable=True),
    sa.Column('follow_id', sa.Integer(), nullable=True),
    sa.ForeignKeyConstraint(['follow_id'], ['user.id'], ),
    sa.ForeignKeyConstraint(['user_id'], ['user.id'], ),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('user_id'),
    sa.UniqueConstraint('user_id', 'follow_id', name='_user_follow_uc')
    )
    op.create_unique_constraint('_user_color_scheme_uc', 'colorscheme', ['user_id', 'shift_category_id'])
    op.add_column('shifttable', sa.Column('end', sa.Time(), nullable=True))
    op.add_column('shifttable', sa.Column('start', sa.Time(), nullable=True))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('shifttable', 'start')
    op.drop_column('shifttable', 'end')
    op.drop_constraint('_user_color_scheme_uc', 'colorscheme', type_='unique')
    op.drop_table('follow')
    # ### end Alembic commands ###
