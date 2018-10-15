"""empty message

Revision ID: e152aa0dade8
Revises: 6400f822d6de
Create Date: 2018-10-15 13:06:33.909178

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'e152aa0dade8'
down_revision = '6400f822d6de'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('shifttable', sa.Column('end', sa.Date(), nullable=True))
    op.add_column('shifttable', sa.Column('start', sa.Date(), nullable=True))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('shifttable', 'start')
    op.drop_column('shifttable', 'end')
    # ### end Alembic commands ###
